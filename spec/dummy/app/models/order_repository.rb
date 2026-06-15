# frozen_string_literal: true

class OrderRepository
  def create(name:)
    Order.create!(name: name)
  end
end
