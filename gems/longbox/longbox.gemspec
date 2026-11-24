require_relative "lib/longbox/version"

# Longbox: the comic-collecting logic behind Comic Stash, as a gem with no
# Rails in it. Loaded by the app's Gemfile with path: "gems/longbox".
Gem::Specification.new do |spec|
  spec.name = "longbox"
  spec.version = Longbox::VERSION
  spec.authors = [ "Ricardo Giacovazzi" ]
  spec.summary = "Run-gap maths for comic collections, and a client for the Metron comics API."
  spec.required_ruby_version = ">= 3.3"
  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = [ "lib" ]
end
