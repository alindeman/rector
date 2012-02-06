require "redis"
require "redis-namespace"

require_relative "rector/configuration"
require_relative "rector/worker"
require_relative "rector/job"
require_relative "rector/backends"

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

    def backend_for(job_id)
      Rector::Backends::Redis.new(job_id)
    end
  end
end
