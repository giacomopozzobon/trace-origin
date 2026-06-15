# frozen_string_literal: true

class ValidateOrderService
  def call(name:)
    raise ArgumentError, "missing name" if name.blank?
  end
end
