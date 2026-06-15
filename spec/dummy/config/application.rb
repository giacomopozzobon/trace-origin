# frozen_string_literal: true

require_relative "boot"

require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = false
    config.active_job.queue_adapter = :test
    config.eager_load = false
  end
end
