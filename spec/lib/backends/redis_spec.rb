require "spec_helper"

describe Rector::Backends::Redis do
  let(:redis) { stub("redis") }

  before do
    Rector.configure do |c|
      c.redis = redis
    end
  end

  let(:namespace) { "abc123" }
  subject         { described_class.new(namespace) }

  it "namespaces values" do
    subject["foo"] = 1

    redis.expects(:sadd).with("#{namespace}:__keys__", "foo")
    redis.expects(:incrby).with("#{namespace}:foo", 1)
    subject.save
  end
end
