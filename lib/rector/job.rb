require "delegate"
require "securerandom"

module Rector
  class Job
    class WorkerCollection < SimpleDelegator
      def initialize(job)
        @job = job

        # Wraps an array
        super(Array.new)
      end

      def create
        Rector::Worker.new(@job.allocate_worker_id).tap do |worker|
          self << worker
        end
      end
    end

    attr_reader :workers

    def initialize
      @workers = WorkerCollection.new(self)
      @backend = Rector.backend_for(id)
    end

    def id
      # TODO: Obviously there's a small chance of jobs overlapping here
      # Can do something more reliable for ID generation?
      @id ||= SecureRandom.hex(8)
    end

    def allocate_worker_id
      # TODO: Obviously there's a small chance of jobs overlapping here
      # Can do something more reliable for ID generation?
      "#{id}:#{SecureRandom.hex(10)}"
    end

    def join
      while @backend.workers_working?
        sleep 5
      end
    end
  end
end
