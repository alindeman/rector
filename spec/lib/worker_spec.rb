require "spec_helper"

describe Rector::Worker do
  let(:worker_id) { "zyx987:abc123" }
  subject         { described_class.new(worker_id) }

  let(:backend)   { stub_everything("backend") }
  before do
    Rector.stubs(:backend_for).returns(backend)
  end

  it "is initialized with a worker ID" do
    subject.id.should == worker_id
  end

  it "knows its job ID" do
    subject.job_id.should == "zyx987"
  end

  describe "#finish" do
    it "notifies the backend" do
      backend.expects(:finish_worker).with(worker_id)
      subject.finish
    end
  end
end
