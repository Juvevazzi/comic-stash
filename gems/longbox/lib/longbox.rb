require "set"
require_relative "longbox/version"
require_relative "longbox/issue_number"
require_relative "longbox/run"

# Longbox: the comic-collecting logic behind Comic Stash, kept out of Rails so
# it can be tested on its own. Run works out what is missing from a series;
# from step 19, Longbox::Metron talks to the Metron comics database.
module Longbox
end
