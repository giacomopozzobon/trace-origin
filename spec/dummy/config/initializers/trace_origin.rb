# frozen_string_literal: true

TraceOrigin.configure do |config|
  config.enabled = true
  config.depth = 10
  config.retention_days = 14
  config.raise_errors = false
end
