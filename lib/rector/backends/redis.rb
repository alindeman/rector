module Rector
  module Backends
    class Redis
      KEY_LIST_SET = "__keys__"

      def initialize(namespace)
        @namespace = namespace
      end

      def redis
        @redis ||=
          ::Redis::Namespace.new(@namespace, redis: Rector.configuration.redis)
      end

      def update_from_hash(hsh)
        redis.multi do
          redis.sadd(KEY_LIST_SET, *hsh.keys)

          hsh.each do |key, val|
            case val
            when Numeric
              redis.incrby(key, val)
            when Set
              redis.sadd(key, *val)
            when Enumerable
              redis.rpush(key, *val)
            end
          end
        end
      end

      def read_to_hash
        Hash[keys.map { |k| [k, read(k)] }]
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
