# frozen_string_literal: true

module TraceOrigin
  class Configuration
    attr_accessor :enabled,
                  :depth,
                  :retention_days,
                  :raise_errors

    def initialize
      @enabled = true
      @depth = 5
      @retention_days = 14
      @raise_errors = false
    end
  end
end
