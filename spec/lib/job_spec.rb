require "spec_helper"
require "timeout"

describe Rector::Job do
  let(:backend) { stub_everything("backend") }
  before do
    Rector.stubs(:backend_for).returns(backend)
  end

  it "constructs workers" do
    worker = subject.workers.create
    worker.should be_a(Rector::Worker)
  end

  it "waits for workers to complete" do
    backend.expects(:workers_working?).at_least_once.returns(true).then.returns(false)
    subject.stubs(:sleep)

    Timeout.timeout(2) do
      subject.join
    end
  end
end
