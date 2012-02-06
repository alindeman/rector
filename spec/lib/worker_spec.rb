require "spec_helper"

describe Rector::Worker do
  let(:worker_id) { "abc123" }
  subject         { described_class.new(worker_id) }

  it "is initialized with a worker ID" do
    subject.id.should == worker_id
  end
end
