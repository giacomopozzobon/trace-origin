# frozen_string_literal: true

RSpec.describe TraceOrigin::Configuration do
  it "has default values" do
    config = described_class.new

    expect(config.enabled).to eq(true)
    expect(config.depth).to eq(5)
    expect(config.retention_days).to eq(14)
    expect(config.raise_errors).to eq(false)
  end
end

RSpec.describe TraceOrigin do
  it "has a version number" do
    expect(TraceOrigin::VERSION).not_to be_nil
  end

  it "allows global configuration" do
    TraceOrigin.configure do |config|
      config.enabled = false
      config.depth = 3
      config.retention_days = 30
    end

    expect(TraceOrigin.configuration.enabled).to eq(false)
    expect(TraceOrigin.configuration.depth).to eq(3)
    expect(TraceOrigin.configuration.retention_days).to eq(30)
  end
end
