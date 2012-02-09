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

    attr_reader :id, :workers

    # TODO: Obviously there's a small chance of jobs overlapping here
    # Can do something more reliable for ID generation?
    def initialize(id = SecureRandom.hex(10))
      @id      = id
      @workers = WorkerCollection.new(self)
      @backend = Rector.backend_for(id)
    end

    def allocate_worker_id
      # TODO: Obviously there's a small chance of jobs overlapping here
      # Can do something more reliable for ID generation?
      "#{id}:#{SecureRandom.hex(8)}"
    end

    def join
      while num_workers_working > 0
        sleep 5
      end
    end

    def num_workers_working
      @backend.num_workers_working
    end

    def data
      @data ||= @backend.read_job_data_to_hash
    end

    def cleanup
      @backend.cleanup
    end
  end
end
