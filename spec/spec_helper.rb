# frozen_string_literal: true

require "logger"
require "active_support/all"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :trace_origins, force: true do |t|
    t.string :record_type, null: false
    t.bigint :record_id, null: false
    t.text :trace, null: false
    t.timestamps
  end

  create_table :orders, force: true do |t|
    t.string :name
    t.timestamps
  end
end

require "trace_origin"

Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |file| require file }

ActiveRecord::Base.extend(TraceOrigin::DSL)

module TraceOrigin
  Location = Struct.new(:path, :lineno, :label, keyword_init: true)
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    TraceOrigin.configuration = TraceOrigin::Configuration.new
    TraceOrigin::Entry.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM orders") if ActiveRecord::Base.connection.table_exists?(:orders)
  end
end
