# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simplydb/version"

Gem::Specification.new do |s|
  s.name        = "simplydb"
  s.version     = Simplydb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["JT Archie"]
  s.email       = ["jtarchie@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/simplydb"
  s.summary     = %q{Simple interface for SimpleDB.}
  s.description = %q{Simple interface for SimpleDB.}

  s.rubyforge_project = "simplydb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "sinatra"
  s.add_dependency "nokogiri"
  s.add_dependency "rest-client"
  s.add_dependency "json"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "timecop"
end
