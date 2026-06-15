# frozen_string_literal: true

module TraceOrigin
  class LocationFormatter
    TYPE_DIRECTORIES = %w[controllers services jobs models mailers].freeze

    def initialize(location, root)
      @location = location
      @root = root
    end

    def format
      if job?
        class_name || fallback
      elsif class_name
        "#{class_name}##{method_name}"
      else
        fallback
      end
    end

    private

    def job?
      @location.path.include?("/jobs/") && @location.path.end_with?("_job.rb")
    end

    def method_name
      label = @location.label
      label.start_with?("block in ") ? label.delete_prefix("block in ") : label
    end

    def class_name
      relative = relative_path
      return nil unless relative

      parts = relative.split("/")
      filename = parts.pop
      name = filename.delete_suffix(".rb").camelize

      parts.shift if TYPE_DIRECTORIES.include?(parts.first)

      namespace_parts = parts.map(&:camelize)
      (namespace_parts + [name]).join("::")
    end

    def relative_path
      app_prefix = File.join(@root, "app/")
      lib_prefix = File.join(@root, "lib/")

      if @location.path.start_with?(app_prefix)
        @location.path.delete_prefix(app_prefix)
      elsif @location.path.start_with?(lib_prefix)
        @location.path.delete_prefix(lib_prefix)
      end
    end

    def fallback
      path =
        if @location.path.start_with?(@root)
          @location.path.delete_prefix("#{@root}/")
        else
          @location.path
        end

      "#{path}:#{@location.lineno}"
    end
  end
end
