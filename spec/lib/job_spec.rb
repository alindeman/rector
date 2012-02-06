require "spec_helper"

describe Rector::Job do
  let(:backend) { stub_everything("backend") }
  before do
    Rector.stubs(:backend_for).returns(backend)
  end

  it "constructs workers" do
    worker = subject.workers.create
    worker.should be_a(Rector::Worker)
  end
end
