require "spec_helper"

describe Rector::Configuration do
  it "accepts and stores arbitrary configuration items" do
    subject.backend = :redis

    subject.backend.should == :redis
  end
end
