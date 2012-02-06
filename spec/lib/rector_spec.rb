require "spec_helper"

describe Rector do
  it "allows configuration by yielding a block to #configure" do
    described_class.configure do |c|
      c.foo = :bar
    end

    described_class.configuration.foo.should == :bar
  end
end
