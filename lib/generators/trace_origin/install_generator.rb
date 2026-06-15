# frozen_string_literal: true

require "rails/generators/migration"

module TraceOrigin
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(dirname)
        next_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_number)
      end

      def copy_initializer
        template(
          "trace_origin.rb",
          "config/initializers/trace_origin.rb"
        )
      end

      def copy_migration
        migration_template(
          "create_trace_origins.rb",
          "db/migrate/create_trace_origins.rb"
        )
      end
    end
  end
end
