# frozen_string_literal: true

module TraceOrigin
  module Model
    extend ActiveSupport::Concern

    included do |base|
      after_create :store_trace_origin

      has_one :trace_origin_record,
              -> { where(record_type: base.name) },
              class_name: "TraceOrigin::Entry",
              foreign_key: :record_id,
              inverse_of: false,
              dependent: :destroy
    end

    def trace_origin
      trace_origin_record&.trace
    end

    private

    def store_trace_origin
      return unless TraceOrigin.configuration.enabled

      trace = TraceOrigin::TraceBuilder.new.build
      return if trace.blank?

      create_trace_origin_record!(trace: trace)
    rescue StandardError => e
      log_trace_origin_error(e)
      raise if TraceOrigin.configuration.raise_errors
    end

    def log_trace_origin_error(error)
      message = "[TraceOrigin] #{error.class}: #{error.message}"

      if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
        Rails.logger.warn(message)
      else
        warn(message)
      end
    end
  end
end
