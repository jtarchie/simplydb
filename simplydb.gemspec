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
  
  s.add_dependency "sinatra", "1.3.1"
  s.add_dependency "nokogiri", "1.5.0"
  s.add_dependency "rest-client", "1.6.7"
  s.add_dependency "json", "1.6.3"
  s.add_development_dependency "rspec", "2.7.0"
  s.add_development_dependency "rack-test", "0.6.1"
  s.add_development_dependency "webmock", "1.7.8"
  s.add_development_dependency "vcr", "1.11.3"
  s.add_development_dependency "timecop", "0.3.5"
  s.add_development_dependency "tzinfo"
end
