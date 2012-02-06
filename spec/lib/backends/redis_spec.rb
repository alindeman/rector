require "spec_helper"

describe Rector::Backends::Redis do
  let(:redis) { stub_everything("redis") }

  before do
    Rector.configure do |c|
      c.redis = redis
    end
  end

  let(:namespace) { "abc123" }
  subject         { described_class.new(namespace) }

  it "stores a list of keys" do
    subject["foo"] = 1
    subject["bar"] = 2

    redis.expects(:sadd).with("#{namespace}:__keys__", "foo")
    redis.expects(:sadd).with("#{namespace}:__keys__", "bar")
    subject.save
  end

  it "stores integers" do
    subject["foo"] = 1

    redis.expects(:incrby).with("#{namespace}:foo", 1)
    subject.save
  end

  it "stores lists" do
    subject["foo"] = ["a", "b", "c"]

    redis.expects(:rpush).with("#{namespace}:foo", "a")
    redis.expects(:rpush).with("#{namespace}:foo", "b")
    redis.expects(:rpush).with("#{namespace}:foo", "c")
    subject.save
  end

  it "stores sets" do
    subject["foo"] = Set.new(["a", "b", "c"])

    redis.expects(:sadd).with("#{namespace}:foo", "a")
    redis.expects(:sadd).with("#{namespace}:foo", "b")
    redis.expects(:sadd).with("#{namespace}:foo", "c")
    subject.save
  end
end
