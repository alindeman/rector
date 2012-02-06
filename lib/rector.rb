require "redis"
require "redis-namespace"

require_relative "rector/configuration"
require_relative "rector/worker"
require_relative "rector/backends"
require_relative "rector/data"

module Rector
  class << self
    def configuration
      @configuration ||= Rector::Configuration.new
    end

    def reset
      @configuration = nil
    end

    def configure
      yield configuration
    end
  end
end
