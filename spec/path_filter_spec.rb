# frozen_string_literal: true

RSpec.describe TraceOrigin::PathFilter do
  subject(:filter) { described_class.new(root: "/app") }

  it "accepts app paths" do
    location = TraceOrigin::Location.new(
      path: "/app/app/services/create_order_service.rb",
      lineno: 12,
      label: "call"
    )

    expect(filter.relevant?(location)).to be(true)
  end

  it "accepts lib paths" do
    location = TraceOrigin::Location.new(
      path: "/app/lib/import_helper.rb",
      lineno: 4,
      label: "run"
    )

    expect(filter.relevant?(location)).to be(true)
  end

  it "rejects active_record frames" do
    location = TraceOrigin::Location.new(
      path: "/usr/local/bundle/gems/activerecord-7.1.0/lib/active_record/persistence.rb",
      lineno: 100,
      label: "create!"
    )

    expect(filter.relevant?(location)).to be(false)
  end

  it "rejects ruby internals" do
    location = TraceOrigin::Location.new(
      path: "/Users/me/.rbenv/versions/3.3.0/lib/ruby/3.3.0/pathname.rb",
      lineno: 50,
      label: "join"
    )

    expect(filter.relevant?(location)).to be(false)
  end

  it "rejects trace_origin gem paths through the generic gems filter" do
    location = TraceOrigin::Location.new(
      path: "/usr/local/bundle/gems/trace_origin-0.1.0/lib/trace_origin/model.rb",
      lineno: 25,
      label: "store_trace_origin"
    )

    expect(filter.relevant?(location)).to be(false)
  end

  it "rejects delayed_job gem paths through the generic gems filter" do
    location = TraceOrigin::Location.new(
      path: "/usr/local/bundle/gems/delayed_job-4.1.11/lib/delayed/job.rb",
      lineno: 314,
      label: "invoke_job"
    )

    expect(filter.relevant?(location)).to be(false)
  end

  it "rejects application_controller frames" do
    location = TraceOrigin::Location.new(
      path: "/app/app/controllers/application_controller.rb",
      lineno: 10,
      label: "with_request_context"
    )

    expect(filter.relevant?(location)).to be(false)
  end

  it "accepts app paths when the project directory contains trace_origin in its name" do
    filter = described_class.new(root: "/tmp/trace_origin_shop")
    location = TraceOrigin::Location.new(
      path: "/tmp/trace_origin_shop/app/services/create_order_service.rb",
      lineno: 12,
      label: "call"
    )

    expect(filter.relevant?(location)).to be(true)
  end
end
