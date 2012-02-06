require "forwardable"

module Rector
  module Backends
    class Redis
      extend Forwardable

      KEYS_LIST_KEY = "__keys__"

      attr_reader :namespace

      def_delegators :@data, :[], :[]=

      def initialize(namespace)
        @namespace = namespace
        @data      = Hash.new(0)
      end

      def redis
        @redis ||=
          ::Redis::Namespace.new(namespace, redis: Rector.configuration.redis)
      end

      def save
        redis.multi do
          @data.each do |key, val|
            redis.sadd(KEYS_LIST_KEY, key)

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
    end
  end
end
