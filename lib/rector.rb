require "redis"

require_relative "rector/configuration"
require_relative "rector/worker"

module Rector
  class << self
    def configuration
      @configuration ||= Rector::Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
