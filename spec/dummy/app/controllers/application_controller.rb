# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # around_action keeps ApplicationController on the stack while the action
  # runs, matching typical real apps (auth, tenant, logging wrappers).
  around_action :with_request_context

  private

  def with_request_context
    @request_id = SecureRandom.uuid
    yield
  end
end
