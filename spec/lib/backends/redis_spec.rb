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

  let(:job_id) { "abc123" }
  subject         { described_class.new(job_id) }

  describe "writing" do
    it "stores a list of keys" do
      hsh = {
        "foo" => 1,
        "bar" => 2
      }

      redis.expects(:sadd).with("#{job_id}:__keys__", "foo")
      redis.expects(:sadd).with("#{job_id}:__keys__", "bar")
      subject.update_job_data_from_hash(hsh)
    end

    it "stores integers" do
      hsh = { "foo" => 1 }

      redis.expects(:incrby).with("#{job_id}:foo", 1)
      subject.update_job_data_from_hash(hsh)
    end

    it "stores lists" do
      hsh = { "foo" => ["a", "b", "c"] }

      redis.expects(:rpush).with("#{job_id}:foo", "a")
      redis.expects(:rpush).with("#{job_id}:foo", "b")
      redis.expects(:rpush).with("#{job_id}:foo", "c")
      subject.update_job_data_from_hash(hsh)
    end

    it "stores sets" do
      hsh = { "foo" => Set.new(["a", "b", "c"]) }

      redis.expects(:sadd).with("#{job_id}:foo", "a")
      redis.expects(:sadd).with("#{job_id}:foo", "b")
      redis.expects(:sadd).with("#{job_id}:foo", "c")
      subject.update_job_data_from_hash(hsh)
    end
  end

  describe "reading" do
    it "reads integers" do
      redis.stubs(:smembers).with("#{job_id}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{job_id}:foo").returns("string")
      redis.stubs(:get).with("#{job_id}:foo").returns("5")

      subject.read_job_data_to_hash.should == { "foo" => 5 }
    end

    it "reads lists" do
      redis.stubs(:smembers).with("#{job_id}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{job_id}:foo").returns("list")
      redis.stubs(:lrange).with("#{job_id}:foo", 0, -1).returns(["bar"])

      subject.read_job_data_to_hash.should == { "foo" => ["bar"] }
    end

    it "reads sets" do
      redis.stubs(:smembers).with("#{job_id}:__keys__").returns(["foo"])

      redis.stubs(:type).with("#{job_id}:foo").returns("set")
      redis.stubs(:smembers).with("#{job_id}:foo").returns(["bar"])

      subject.read_job_data_to_hash.should == { "foo" => Set.new(["bar"]) }
    end
  end

  describe "workers" do
    it "adds a worker to a set" do
      redis.expects(:sadd).with("#{job_id}:__workers__", "1234:5678")
      subject.add_worker("1234:5678")
    end

    it "removes a worker from the set when it is finished" do
      redis.expects(:srem).with("#{job_id}:__workers__", "1234:5678")
      subject.finish_worker("1234:5678")
    end

    it "knows if workers are still working" do
      redis.stubs(:scard).with("#{job_id}:__workers__").returns("1")
      subject.num_workers_working.should == 1

      redis.stubs(:scard).with("#{job_id}:__workers__").returns("0")
      subject.num_workers_working.should == 0
    end
  end

  it "cleans up when requests" do
    redis.stubs(:smembers).returns(["a", "b"])
    redis.expects(:del).with("#{job_id}:a", "#{job_id}:b")
    redis.expects(:del).with("#{job_id}:__keys__", "#{job_id}:__workers__")

    subject.cleanup
  end
end
