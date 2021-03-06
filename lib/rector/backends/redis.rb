require "set"

module Rector
  module Backends
    class Redis
      KEY_LIST_SET    = "__keys__"
      WORKER_LIST_SET = "__workers__"

      attr_reader :job_id

      def initialize(job_id)
        @job_id = job_id
      end

      def update_job_data_from_hash(hsh)
        redis.multi do
          hsh.keys.each { |k| redis.sadd(KEY_LIST_SET, k) }

          hsh.each do |key, val|
            case val
            when Numeric
              redis.incrby(key, val)
            when Set
              val.each { |v| redis.sadd(key, v) }
            when Enumerable
              val.each { |v| redis.rpush(key, v) }
            end
          end
        end
      end

      def read_job_data_to_hash
        Hash[keys.map { |k| [k, read(k)] }]
      end

      def add_worker(worker_id)
        redis.sadd(WORKER_LIST_SET, worker_id)
      end

      def finish_worker(worker_id)
        redis.srem(WORKER_LIST_SET, worker_id)
      end

      def num_workers_working
        redis.scard(WORKER_LIST_SET).to_i
      end

      def cleanup
        redis.del(*keys)
        redis.del(KEY_LIST_SET, WORKER_LIST_SET)
      end

      private

      def redis
        @redis ||=
          ::Redis::Namespace.new(@job_id, redis: Rector.configuration.redis)
      end

      def keys
        redis.smembers(KEY_LIST_SET)
      end

      def read(key)
        case redis.type(key)
        when "string"
          redis.get(key).to_i
        when "set"
          Set.new(redis.smembers(key))
        when "list"
          redis.lrange(key, 0, -1)
        end
      end
    end
  end
end
