# frozen_string_literal: true

class EnqueueImportOrdersService
  def call
    ImportOrdersJob.perform_later
  end
end
