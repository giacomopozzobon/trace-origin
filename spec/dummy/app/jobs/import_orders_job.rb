# frozen_string_literal: true

class ImportOrdersJob < ApplicationJob
  queue_as :default

  def perform
    CreateOrderService.new.call("imported")
  end
end
