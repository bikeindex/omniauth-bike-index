$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "omniauth/bike_index/version"

Gem::Specification.new do |s|
  s.name = "omniauth-bike-index"
  s.version = OmniAuth::BikeIndex::VERSION
  s.authors = ["Seth Herr"]
  s.email = ["seth@bikeidnex.org"]
  s.summary = "Bike Index strategy for OmniAuth"
  s.description = "Bike Index strategy for OmniAuth v1.2"
  s.homepage = "https://github.com/bikeindex/omniauth-bike-index"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").collect { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "omniauth", "~> 1.2"
  s.add_runtime_dependency "omniauth-oauth2", "~> 1.1"

  s.add_development_dependency "dotenv", "~> 0"
  s.add_development_dependency "sinatra", "~> 0"
end
