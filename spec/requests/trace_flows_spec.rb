# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Trace origin flows", type: :request do
  describe "simple path: controller to service" do
    it "captures the controller and service without ApplicationController" do
      post "/api/orders"

      expect(response).to have_http_status(:created)

      order = Order.last
      trace = order.trace_origin

      expect(trace).to include("Api::OrdersController#create")
      expect(trace).to include("CreateOrderService#call")
      expect(trace).not_to include("ApplicationController")
    end
  end

  describe "medium path: controller, facade, services, repository" do
    it "captures the application stack down to the model callback" do
      post "/admin/orders"

      expect(response).to have_http_status(:created)

      order = Order.last
      trace = order.trace_origin

      expect(trace).to include("Admin::OrdersController#create")
      expect(trace).to include("OrderCreationFacade#create")
      expect(trace).to include("PersistOrderService#call")
      expect(trace).to include("OrderRepository#create")
      expect(trace).not_to include("ValidateOrderService#call")
      expect(trace).not_to match(/store_trace_origin|active_record|activesupport/i)
    end
  end

  describe "complex path: controller, service, enqueued job, job execution" do
    it "captures the job stack after the enqueued job runs" do
      post "/api/orders/import"

      expect(response).to have_http_status(:accepted)
      expect(enqueued_jobs.size).to eq(1)
      expect(enqueued_jobs.first[:job]).to eq(ImportOrdersJob)

      perform_enqueued_jobs

      order = Order.last
      trace = order.trace_origin

      expect(trace).to include("ImportOrdersJob")
      expect(trace).to include("CreateOrderService#call")

      expect(trace).not_to include("Api::OrdersController#import")
      expect(trace).not_to include("EnqueueImportOrdersService#call")
    end
  end
end
