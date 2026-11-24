require "json"
require "net/http"
require "uri"

module Longbox
  # Talking to Metron (metron.cloud), the community comics database that
  # Comic Stash gets its series, issues, covers and credits from.
  module Metron
    # Every problem talking to Metron is a Longbox::Metron::Error, so the app
    # can rescue them all in one place, or pick out the ones it handles.
    class Error < StandardError; end
    class AuthenticationError < Error; end # 401: wrong username or password
    class NotFound < Error; end            # 404: no such series or issue
    class ServerError < Error; end         # 5xx: Metron is having problems

    # 429: too many requests. retry_after says how many seconds to wait.
    class RateLimited < Error
      attr_reader :retry_after

      def initialize(message = "Metron's rate limit was reached", retry_after: 60)
        super(message)
        @retry_after = retry_after
      end
    end

    # What a request gets back: the status code, the headers (lower-case
    # names) and the body text. The client only ever sees this, never
    # Net::HTTP directly, which is what lets the tests use a fake.
    Response = Data.define(:status, :headers, :body)
  end
end

require_relative "metron/http_transport"
require_relative "metron/client"
