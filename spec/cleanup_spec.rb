# frozen_string_literal: true

RSpec.describe TraceOrigin::Cleanup do
  it "deletes records older than the retention period" do
    TraceOrigin.configuration.retention_days = 7

    TraceOrigin::Entry.create!(
      record_type: "Order",
      record_id: 1,
      trace: "old",
      created_at: 10.days.ago,
      updated_at: 10.days.ago
    )
    TraceOrigin::Entry.create!(
      record_type: "Order",
      record_id: 2,
      trace: "recent",
      created_at: 1.day.ago,
      updated_at: 1.day.ago
    )

    expect(described_class.call).to eq(1)
    expect(TraceOrigin::Entry.count).to eq(1)
    expect(TraceOrigin::Entry.first.trace).to eq("recent")
  end

  it "does nothing when retention is disabled" do
    TraceOrigin.configuration.retention_days = 0

    TraceOrigin::Entry.create!(
      record_type: "Order",
      record_id: 1,
      trace: "old",
      created_at: 10.days.ago,
      updated_at: 10.days.ago
    )

    expect(described_class.call).to eq(0)
    expect(TraceOrigin::Entry.count).to eq(1)
  end
end
