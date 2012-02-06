module Rector
  class Worker
    attr_reader :id, :data

    def initialize(id)
      @id      = id
      @data    = Hash.new

      @backend = Rector.backend_for(job_id)
      @backend.add_worker(@id)
    end

    def job_id
      @id.split(":").first
    end

    def finish
      @backend.update_job_data_from_hash(@data)
      @backend.finish_worker(@id)
    end
  end
end
