# frozen_string_literal: true

require "active_support/core_ext/numeric/time"

module TraceOrigin
  class Cleanup
    def self.call
      retention_days = TraceOrigin.configuration.retention_days
      return 0 if retention_days.nil? || retention_days <= 0

      cutoff = retention_days.days.ago
      Entry.where(created_at: ...cutoff).delete_all
    end
  end
end
