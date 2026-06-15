# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

ActiveRecord::Schema.verbose = false
load File.expand_path("dummy/db/schema.rb", __dir__)

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:each, type: :request) do
    TraceOrigin.configuration = TraceOrigin::Configuration.new
    TraceOrigin.configuration.depth = 10
    TraceOrigin::Entry.delete_all
    Order.delete_all
    clear_enqueued_jobs
  end
end
