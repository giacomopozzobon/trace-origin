# frozen_string_literal: true

module Api
  class OrdersController < ApplicationController
    def create
      order = CreateOrderService.new.call
      render json: { id: order.id }, status: :created
    end

    def import
      EnqueueImportOrdersService.new.call
      head :accepted
    end
  end
end
