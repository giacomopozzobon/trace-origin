# frozen_string_literal: true

require_relative "trace_origin/version"
require_relative "trace_origin/configuration"
require_relative "trace_origin/path_filter"
require_relative "trace_origin/location_formatter"
require_relative "trace_origin/trace_builder"
require_relative "trace_origin/cleanup"
require_relative "trace_origin/dsl"
require_relative "trace_origin/model"
require_relative "trace_origin/entry"

require_relative "trace_origin/railtie" if defined?(Rails::Railtie)

module TraceOrigin
  GEM_LIB = File.expand_path("trace_origin", __dir__)

  class Error < StandardError; end

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configuration=(value)
      @configuration = value
    end
  end
end
