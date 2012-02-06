require "spec_helper"

describe Rector do
  it "allows configuration by yielding a block to #configure" do
    described_class.configure do |c|
      c.foo = :bar
    end

    described_class.configuration.foo.should == :bar
  end

  it "creates backend objects for jobs" do
    backend = described_class.backend_for("abc123")

    backend.should be_a(Rector::Backends::Redis)
    backend.job_id.should == "abc123"
  end
end
