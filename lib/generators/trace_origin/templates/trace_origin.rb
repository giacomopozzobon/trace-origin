TraceOrigin.configure do |config|
  config.enabled = ENV.fetch("TRACE_ORIGIN_ENABLED", Rails.env.development? ? "true" : "false") == "true"
  config.depth = ENV.fetch("TRACE_ORIGIN_DEPTH", 5).to_i
  config.retention_days = ENV.fetch("TRACE_ORIGIN_RETENTION_DAYS", 14).to_i
  config.raise_errors = false
end
