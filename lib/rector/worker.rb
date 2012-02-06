module Rector
  class Worker
    attr_reader :id

    def initialize(id)
      @id      = id
      @backend = Rector.backend_for(job_id)
    end

    def job_id
      @id.split(":").first
    end

    def finish
      @backend.finish_worker(id)
    end
  end
end
