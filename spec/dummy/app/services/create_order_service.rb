# frozen_string_literal: true

class CreateOrderService
  def call(name = "Test")
    Order.create!(name: name)
  end
end
