# -*- encoding: utf-8 -*-
require File.expand_path('../lib/graphable/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joe Fredette", "Andrew Ross"]
  gem.email         = ["jfredett@gmail.com", "andrewslavinross@gmail.com"]
  gem.description   = %q{A library for extracting static graph representations of data from rails-y databases}
  gem.summary       = %q{A library for extracting static graph representations of data from rails-y databases}
  gem.homepage      = "http://www.github.com/jfredett/graphable"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "graphable"
  gem.require_paths = ["lib"]

  gem.add_dependency "activesupport", '~> 3.1'
  gem.add_dependency "neography"

  gem.version       = Graphable::VERSION
end
