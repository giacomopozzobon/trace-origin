# frozen_string_literal: true

class PersistOrderService
  def call(name:)
    OrderRepository.new.create(name: name)
  end
end
