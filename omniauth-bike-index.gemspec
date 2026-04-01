$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "omniauth/bike_index/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-bike-index"
  spec.version = OmniAuth::BikeIndex::VERSION
  spec.authors = ["Bike Index"]
  spec.email = ["seth@bikeindex.org"]
  spec.summary = "Bike Index strategy for OmniAuth"
  spec.description = "Bike Index strategy for OmniAuth"
  spec.homepage = "https://github.com/bikeindex/omniauth-bike-index"
  spec.license = "MIT"
  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bikeindex/omniauth-bike-index/issues",
    "homepage_uri" => "https://github.com/bikeindex/omniauth-bike-index",
    "funding_uri" => "https://github.com/sponsors/bikeindex",
    "rubygems_mfa_required" => "true"
  }

  spec.files = `git ls-files`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "omniauth", "~> 2.0"
  spec.add_runtime_dependency "omniauth-oauth2", "~> 1.8"

  spec.add_development_dependency "dotenv", "~> 0"
  spec.add_development_dependency "sinatra", "~> 0"
end
