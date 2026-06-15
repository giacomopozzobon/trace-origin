# frozen_string_literal: true

namespace :trace_origin do
  desc "Delete expired trace origin records"
  task cleanup: :environment do
    deleted = TraceOrigin::Cleanup.call
    puts "Deleted #{deleted} expired trace origin record(s)."
  end
end
