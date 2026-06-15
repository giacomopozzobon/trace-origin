# frozen_string_literal: true

RSpec.describe TraceOrigin::Model do
  let(:order_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = "orders"
      trace_origin
    end
  end

  before do
    stub_const("Order", order_class)
  end

  it "stores a trace when a record is created" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "Api::OrdersController#create > CreateOrderService#call")
    )

    order = Order.create!(name: "Test")

    entry = TraceOrigin::Entry.find_by(record_type: "Order", record_id: order.id)

    expect(entry.trace).to eq("Api::OrdersController#create > CreateOrderService#call")
  end

  it "does not store a trace when disabled" do
    TraceOrigin.configuration.enabled = false

    allow(TraceOrigin::TraceBuilder).to receive(:new)

    order = Order.create!(name: "Test")

    expect(TraceOrigin::TraceBuilder).not_to have_received(:new)
    expect(TraceOrigin::Entry.find_by(record_type: "Order", record_id: order.id)).to be_nil
  end

  it "returns the trace through trace_origin" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "ImportOrdersJob")
    )

    order = Order.create!(name: "Test")

    expect(order.trace_origin).to eq("ImportOrdersJob")
  end

  it "returns the persisted entry through trace_origin_record" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "ImportOrdersJob")
    )

    order = Order.create!(name: "Test")

    expect(order.trace_origin_record).to be_a(TraceOrigin::Entry)
    expect(order.trace_origin_record.trace).to eq("ImportOrdersJob")
  end

  it "does not fail record creation when trace persistence fails" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "ImportOrdersJob")
    )
    allow_any_instance_of(order_class).to receive(:create_trace_origin_record!).and_raise(
      ActiveRecord::StatementInvalid,
      "database unavailable"
    )

    expect { Order.create!(name: "Test") }.not_to raise_error
    expect(Order.last.name).to eq("Test")
    expect(TraceOrigin::Entry.count).to eq(0)
  end

  it "does not persist an empty trace" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "")
    )

    order = Order.create!(name: "Test")

    expect(order.trace_origin_record).to be_nil
  end

  it "re-raises when raise_errors is enabled" do
    TraceOrigin.configuration.raise_errors = true

    allow(TraceOrigin::TraceBuilder).to receive(:new).and_raise(StandardError, "boom")

    expect { Order.create!(name: "Test") }.to raise_error(StandardError, "boom")
  end

  it "preloads trace records without N+1 queries" do
    allow(TraceOrigin::TraceBuilder).to receive(:new).and_return(
      instance_double(TraceOrigin::TraceBuilder, build: "ImportOrdersJob")
    )

    3.times { Order.create!(name: "Test") }

    query_count = 0
    callback = lambda do |*, payload|
      query_count += 1 unless payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      Order.includes(:trace_origin_record).map(&:trace_origin)
    end

    expect(query_count).to eq(2)
  end
end
