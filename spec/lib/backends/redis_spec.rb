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
      subject.update_job_data_from_hash(hsh)
    end

    it "stores integers" do
      hsh = { "foo" => 1 }

      redis.expects(:incrby).with("#{namespace}:foo", 1)
      subject.update_job_data_from_hash(hsh)
    end

    it "stores lists" do
      hsh = { "foo" => ["a", "b", "c"] }

      redis.expects(:rpush).with("#{namespace}:foo", "a", "b", "c")
      subject.update_job_data_from_hash(hsh)
    end

    it "stores sets" do
      hsh = { "foo" => Set.new(["a", "b", "c"]) }

      redis.expects(:sadd).with("#{namespace}:foo", "a", "b", "c")
      subject.update_job_data_from_hash(hsh)
    end
  end

  describe "reading" do
    it "reads integers" do
      redis.stubs(:smembers).with("#{namespace}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{namespace}:foo").returns("string")
      redis.stubs(:get).with("#{namespace}:foo").returns("5")

      subject.read_job_data_to_hash.should == { "foo" => 5 }
    end

    it "reads lists" do
      redis.stubs(:smembers).with("#{namespace}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{namespace}:foo").returns("list")
      redis.stubs(:lrange).with("#{namespace}:foo", 0, -1).returns(["bar"])

      subject.read_job_data_to_hash.should == { "foo" => ["bar"] }
    end

    it "reads sets" do
      redis.stubs(:smembers).with("#{namespace}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{namespace}:foo").returns("set")
      redis.stubs(:smembers).with("#{namespace}:foo").returns(["bar"])

      subject.read_job_data_to_hash.should == { "foo" => Set.new(["bar"]) }
    end
  end
end
