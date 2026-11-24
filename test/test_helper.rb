ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/fake_metron"
require_relative "test_helpers/session_test_helper"
require_relative "test_helpers/stash_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # add_series, for tests that need a bigger stash than the fixtures.
    include StashTestHelper
  end
end
