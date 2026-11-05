module Longbox
  module Metron
    # A small client for Metron's REST API (https://metron.cloud/docs/).
    #
    #   client = Longbox::Metron::Client.new(token: "...")
    #   client.search_series("Paper Moons")  # => [{"id" => 1234, "series" => "Paper Moons (2022)", ...}]
    #   client.series(1234)                   # => {"id" => 1234, "name" => "Paper Moons", ...}
    #   client.series_issues(1234)            # => every issue, all pages
    #   client.issue(56789)                   # => one issue with credits, characters...
    #
    # Results are Metron's JSON as plain Hashes; the app decides what to keep.
    class Client
      BASE_URL = "https://metron.cloud/api/".freeze
      USER_AGENT = "ComicStash/#{VERSION} (Longbox Ruby gem)".freeze

      # The rate-limit headers from the last response, e.g.
      # { burst_remaining: 19, sustained_remaining: 4999 }.
      attr_reader :rate_limit

      # token: an API token from your Metron profile page (API Tokens).
      # transport: anything with call(uri, headers) that returns a Response.
      # Leave it out to use the real network; the tests pass a fake.
      def initialize(token:, transport: HttpTransport.new, base_url: BASE_URL)
        raise ArgumentError, "a Metron API token is required" if token.to_s.strip.empty?

        @token = token
        @transport = transport
        @base_url = base_url
        @rate_limit = {}
      end

      # GET /series/?name=... (first page of matches is enough for a search box)
      def search_series(name)
        get("series/", name: name).fetch("results")
      end

      # GET /series/{id}/
      def series(id)
        get("series/#{Integer(id)}/")
      end

      # GET /series/{id}/issue_list/, following "next" until the last page.
      def series_issues(series_id)
        all_pages("series/#{Integer(series_id)}/issue_list/")
      end

      # GET /issue/{id}/
      def issue(id)
        get("issue/#{Integer(id)}/")
      end

      private

      def all_pages(path)
        page = get(path)
        results = page.fetch("results").dup
        while (next_url = page["next"])
          page = request(same_site!(URI(next_url)))
          results.concat(page.fetch("results"))
        end
        results
      end

      # Only follow "next" links back to Metron itself, never somewhere else,
      # because every request carries the username and password.
      def same_site!(uri)
        return uri if uri.host == URI(@base_url).host

        raise Error, "Metron's next page pointed to another site"
      end

      def get(path, query = {})
        uri = URI.join(@base_url, path)
        uri.query = URI.encode_www_form(query) unless query.empty?
        request(uri)
      end

      def request(uri)
        response = @transport.call(uri, headers)
        remember_rate_limit(response.headers)
        handle(response)
      end

      def headers
        {
          "Authorization" => "Bearer #{@token}",
          "Accept" => "application/json",
          "User-Agent" => USER_AGENT
        }
      end

      # Turns the status code into a result or one of the Metron errors.
      # Messages never include the credentials or the full URL.
      def handle(response)
        case response.status
        when 200 then JSON.parse(response.body)
        when 401, 403 then raise AuthenticationError, "Metron refused the API token"
        when 404 then raise NotFound, "Metron has no record at that address"
        when 429 then raise RateLimited.new(retry_after: retry_after(response.headers))
        when 500..599 then raise ServerError, "Metron returned #{response.status}; try again later"
        else raise Error, "Unexpected response from Metron: #{response.status}"
        end
      rescue JSON::ParserError
        raise Error, "Metron sent something that isn't JSON"
      end

      def retry_after(headers)
        Integer(headers["retry-after"] || 60)
      rescue ArgumentError
        60
      end

      def remember_rate_limit(headers)
        @rate_limit = {
          burst_remaining: headers["x-ratelimit-burst-remaining"]&.to_i,
          sustained_remaining: headers["x-ratelimit-sustained-remaining"]&.to_i
        }.compact
      end
    end
  end
end
