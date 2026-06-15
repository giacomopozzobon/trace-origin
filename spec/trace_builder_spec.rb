# frozen_string_literal: true

RSpec.describe TraceOrigin::TraceBuilder do
  let(:root) { "/app" }

  def build_with(locations)
    described_class.new(locations: locations, root: root).build
  end

  it "joins normalized locations with >" do
    locations = [
      TraceOrigin::Location.new(
        path: "/app/app/services/create_order_service.rb",
        lineno: 12,
        label: "call"
      ),
      TraceOrigin::Location.new(
        path: "/app/app/controllers/api/orders_controller.rb",
        lineno: 8,
        label: "create"
      )
    ]

    trace = build_with(locations)

    expect(trace).to eq("Api::OrdersController#create > CreateOrderService#call")
  end

  it "filters out framework noise" do
    locations = [
      TraceOrigin::Location.new(
        path: "/usr/local/bundle/gems/activerecord-7.1.0/lib/active_record/persistence.rb",
        lineno: 100,
        label: "create!"
      ),
      TraceOrigin::Location.new(
        path: "/app/app/jobs/import_orders_job.rb",
        lineno: 5,
        label: "perform"
      )
    ]

    trace = build_with(locations)

    expect(trace).to eq("ImportOrdersJob")
  end

  it "respects configured depth" do
    TraceOrigin.configuration.depth = 1

    locations = [
      TraceOrigin::Location.new(
        path: "/app/app/services/create_order_service.rb",
        lineno: 12,
        label: "call"
      ),
      TraceOrigin::Location.new(
        path: "/app/app/controllers/api/orders_controller.rb",
        lineno: 8,
        label: "create"
      )
    ]

    trace = build_with(locations)

    expect(trace).to eq("Api::OrdersController#create")
  end

  it "rejects trace_origin gem internal frames" do
    locations = [
      TraceOrigin::Location.new(
        path: File.join(TraceOrigin::GEM_LIB, "model.rb"),
        lineno: 25,
        label: "store_trace_origin"
      ),
      TraceOrigin::Location.new(
        path: "/app/app/services/create_order_service.rb",
        lineno: 12,
        label: "call"
      )
    ]

    trace = build_with(locations)

    expect(trace).to eq("CreateOrderService#call")
  end

  it "returns an empty string when no relevant locations exist" do
    locations = [
      TraceOrigin::Location.new(
        path: "/usr/local/bundle/gems/activerecord-7.1.0/lib/active_record/persistence.rb",
        lineno: 100,
        label: "create!"
      )
    ]

    trace = build_with(locations)

    expect(trace).to eq("")
  end
end
