# Rector

[![Build Status](https://secure.travis-ci.org/alindeman/rector.png)](http://travis-ci.org/alindeman/rector)

** RECTOR IS CURRENTLY VAPORWARE; THIS README IS SIMPLY MY THOUGHTS ON
HOW IT MIGHT WORK **

Rector allows coordination of a number of jobs spawned with a mechanism
like Resque (though any job manager will do). If you are able to parallelize
the processing of a task, yet all these tasks are generating metrics,
statistics, or other data that need to be combined, Rector might be for you.

## Requirements

* Ruby >= 1.9.2 (or 1.9 mode of JRuby or Rubinius)

## Configuration

Rector currently supports Redis as a backend for job coordination and
data storage.

### Redis Server

```ruby
Rector.configure do |c|
  c.redis = Redis.new(:host => "10.0.1.1", :port => 6380)
end
```

## Job Creation (Master)

Rector requires that some process be designated as the "master" process.
This is usually the process that is also responsible for spawning the
worker jobs.

```ruby
job = Rector::Job.new

# e.g., processing files in parallel
files.each do |file|
  worker = job.workers.create

  # e.g., using Resque for job management; Rector doesn't really care
  Resque.enqueue(WordCounterJob, worker.id, file)
end

# wait for all the workers to complete
job.join

# get aggregated data from all the jobs
job.data.each do |word, count|
  puts "#{word} was seen #{count} times across all files"
end
```

## Job Processing (Workers)

```ruby
class ProcessFileJob
  def self.perform(worker_id, file)
    worker = Rector::Worker.new(worker_id)

    words = File.read(file).split(/\W/)
    words.reject(&:blank?).each do |word|
      worker.data[word] ||= 0 
      worker.data[word]  += 1
    end

    worker.finish
  end
end
```
