# frozen_string_literal: true

module TraceOrigin
  class PathFilter
    NOISE_PATTERN = %r{
      (?:^|/)
      (?:
        ruby/ |
        bundler/ |
        gems/ |
        gem/ |
        active_record |
        activerecord |
        active_support |
        activesupport |
        railties/ |
        actionpack |
        actionview
      )
    }xi

    def initialize(root:)
      @root = root
      @app_prefix = File.join(root, "app")
      @lib_prefix = File.join(root, "lib")
    end

    def relevant?(location)
      app_or_lib?(location.path) && !noise?(location.path)
    end

    private

    def app_or_lib?(path)
      path.start_with?(@app_prefix, @lib_prefix)
    end

    def application_controller?(path)
      path.end_with?("/application_controller.rb")
    end

    def noise?(path)
      path.match?(NOISE_PATTERN) || application_controller?(path)
    end
  end
end
