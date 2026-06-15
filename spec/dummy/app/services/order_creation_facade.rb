# frozen_string_literal: true

class OrderCreationFacade
  def create(name:)
    ValidateOrderService.new.call(name: name)
    PersistOrderService.new.call(name: name)
  end
end
