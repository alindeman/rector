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
        @data.each do |key, val|
          redis.sadd(KEYS_LIST_KEY, key)
          redis.incrby(key, val)
        end
      end
    end
  end
end
