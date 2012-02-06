require "spec_helper"

describe Rector::Backends::Redis do
  let(:redis) { stub_everything("redis") }

  before do
    def redis.multi
      yield
    end

    Rector.configure do |c|
      c.redis = redis
    end
  end

  let(:namespace) { "abc123" }
  subject         { described_class.new(namespace) }

  describe "writing" do
    it "stores a list of keys" do
      hsh = {
        "foo" => 1,
        "bar" => 2
      }

      redis.expects(:sadd).with("#{namespace}:__keys__", "foo", "bar")
      subject.update_from_hash(hsh)
    end

    it "stores integers" do
      hsh = { "foo" => 1 }

      redis.expects(:incrby).with("#{namespace}:foo", 1)
      subject.update_from_hash(hsh)
    end

    it "stores lists" do
      hsh = { "foo" => ["a", "b", "c"] }

      redis.expects(:rpush).with("#{namespace}:foo", "a", "b", "c")
      subject.update_from_hash(hsh)
    end

    it "stores sets" do
      hsh = { "foo" => Set.new(["a", "b", "c"]) }

      redis.expects(:sadd).with("#{namespace}:foo", "a", "b", "c")
      subject.update_from_hash(hsh)
    end
  end

  describe "reading" do
    it "reads integers" do
      redis.stubs(:smembers).with("#{namespace}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{namespace}:foo").returns("string")
      redis.stubs(:get).with("#{namespace}:foo").returns("5")

      subject.read_to_hash.should == { "foo" => 5 }
    end
  end
end
