# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    def create
      order = OrderCreationFacade.new.create(name: "Test")
      render json: { id: order.id }, status: :created
    end
  end
end
