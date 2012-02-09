# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rector"
  s.version     = "0.0.5"
  s.authors     = ["Andy Lindeman"]
  s.email       = ["alindeman@gmail.com"]
  s.homepage    = "https://github.com/alindeman/rector"
  s.summary     = %q{Rector coordinates parallelized jobs that generate metrics or other data together}
  s.description = <<-EOF
    Rector allows coordination of a number of jobs spawned with a mechanism
    like Resque (though any job manager will do). If you are able to parallelize
    the processing of a task, yet all these tasks are generating metrics,
    statistics, or other data that need to be combined, Rector might be for you.
  EOF

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis"
  s.add_dependency "redis-namespace"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">=2.8.0"
  s.add_development_dependency "mocha", ">=0.10.0"
end
