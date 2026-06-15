# frozen_string_literal: true

RSpec.describe TraceOrigin::LocationFormatter do
  subject(:formatter) { described_class.new(location, "/app") }

  describe "services" do
    let(:location) do
      TraceOrigin::Location.new(
        path: "/app/app/services/create_order_service.rb",
        lineno: 12,
        label: "call"
      )
    end

    it "formats class and method" do
      expect(formatter.format).to eq("CreateOrderService#call")
    end
  end

  describe "controllers" do
    let(:location) do
      TraceOrigin::Location.new(
        path: "/app/app/controllers/api/orders_controller.rb",
        lineno: 8,
        label: "create"
      )
    end

    it "formats namespaced controller actions" do
      expect(formatter.format).to eq("Api::OrdersController#create")
    end
  end

  describe "jobs" do
    let(:location) do
      TraceOrigin::Location.new(
        path: "/app/app/jobs/import_orders_job.rb",
        lineno: 5,
        label: "perform"
      )
    end

    it "formats only the job class name" do
      expect(formatter.format).to eq("ImportOrdersJob")
    end
  end

  describe "block labels" do
    let(:location) do
      TraceOrigin::Location.new(
        path: "/app/app/services/create_order_service.rb",
        lineno: 20,
        label: "block in call"
      )
    end

    it "strips the block prefix" do
      expect(formatter.format).to eq("CreateOrderService#call")
    end
  end

  describe "unknown paths" do
    let(:location) do
      TraceOrigin::Location.new(
        path: "/app/vendor/custom_script.rb",
        lineno: 3,
        label: "run"
      )
    end

    it "falls back to path and line number" do
      expect(formatter.format).to eq("vendor/custom_script.rb:3")
    end
  end

end
