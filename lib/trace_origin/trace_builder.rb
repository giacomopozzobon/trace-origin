# frozen_string_literal: true

module TraceOrigin
  class TraceBuilder
    def initialize(locations: nil, root: nil)
      @locations = locations
      @root = root
    end

    def build
      filtered_locations
        .reverse
        .first(TraceOrigin.configuration.depth)
        .map { |location| LocationFormatter.new(location, application_root).format }
        .join(" > ")
    end

    private

    def filtered_locations
      source = @locations || caller_locations(0, 200)
      source
        .reject { |location| gem_internal?(location.path) }
        .select { |location| path_filter.relevant?(location) }
    end

    def gem_internal?(path)
      path.start_with?("#{TraceOrigin::GEM_LIB}/")
    end

    def path_filter
      @path_filter ||= PathFilter.new(root: application_root)
    end

    def application_root
      @root || (defined?(Rails) && Rails.respond_to?(:root) ? Rails.root.to_s : Dir.pwd)
    end
  end
end
