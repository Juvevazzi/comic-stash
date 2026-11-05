require_relative "test_helper"
require_relative "fake_transport"

class MetronClientTest < Minitest::Test
  def client_with(*responses)
    @transport = FakeTransport.new(*responses)
    Longbox::Metron::Client.new(username: "reader", password: "s3cret", transport: @transport)
  end

  def last_request = @transport.requests.last

  def test_asks_for_a_series_at_the_right_address
    series = client_with(FakeTransport.json({ "id" => 12, "name" => "Paper Moons" })).series(12)

    assert_equal "Paper Moons", series["name"]
    assert_equal "https://metron.cloud/api/series/12/", last_request[:uri]
  end

  def test_logs_in_with_basic_auth_and_names_itself
    client_with(FakeTransport.json({})).issue(5)

    assert_equal "Basic #{[ "reader:s3cret" ].pack("m0")}", last_request[:headers]["Authorization"]
    assert_equal "application/json", last_request[:headers]["Accept"]
    assert_match(/\AComicStash/, last_request[:headers]["User-Agent"])
  end

  def test_search_sends_the_name_as_a_query_and_returns_the_results
    page = { "count" => 1, "next" => nil, "results" => [ { "id" => 12, "series" => "Paper Moons (2022)" } ] }
    results = client_with(FakeTransport.json(page)).search_series("Paper Moons")

    assert_equal [ 12 ], results.map { |row| row["id"] }
    assert_equal "https://metron.cloud/api/series/?name=Paper+Moons", last_request[:uri]
  end

  def test_series_issues_follows_every_page
    first = { "next" => "https://metron.cloud/api/series/12/issue_list/?page=2", "results" => [ { "number" => "1" } ] }
    second = { "next" => nil, "results" => [ { "number" => "2" }, { "number" => "3" } ] }
    issues = client_with(FakeTransport.json(first), FakeTransport.json(second)).series_issues(12)

    assert_equal %w[1 2 3], issues.map { |issue| issue["number"] }
    assert_equal 2, @transport.requests.size
    assert_equal "https://metron.cloud/api/series/12/issue_list/?page=2", last_request[:uri]
  end

  def test_never_follows_a_next_link_to_another_site
    page = { "next" => "https://evil.example/steal", "results" => [] }
    assert_raises(Longbox::Metron::Error) { client_with(FakeTransport.json(page)).series_issues(12) }
    assert_equal 1, @transport.requests.size
  end

  def test_ids_must_be_numbers_so_nothing_odd_reaches_the_url
    assert_raises(ArgumentError) { client_with.series("12/../../user") }
  end

  def test_remembers_the_rate_limit_headers
    headers = { "x-ratelimit-burst-remaining" => "19", "x-ratelimit-sustained-remaining" => "4999" }
    client = client_with(FakeTransport.json({}, headers: headers))
    client.issue(5)

    assert_equal({ burst_remaining: 19, sustained_remaining: 4999 }, client.rate_limit)
  end

  def test_too_many_requests_says_how_long_to_wait
    error = assert_raises(Longbox::Metron::RateLimited) do
      client_with(FakeTransport.json({}, status: 429, headers: { "retry-after" => "42" })).issue(5)
    end
    assert_equal 42, error.retry_after
  end

  def test_wrong_credentials_raise_an_authentication_error_without_the_password
    error = assert_raises(Longbox::Metron::AuthenticationError) do
      client_with(FakeTransport.json({}, status: 401)).issue(5)
    end
    refute_includes error.message, "s3cret"
  end

  def test_unknown_records_and_server_trouble_have_their_own_errors
    assert_raises(Longbox::Metron::NotFound) { client_with(FakeTransport.json({}, status: 404)).issue(5) }
    assert_raises(Longbox::Metron::ServerError) { client_with(FakeTransport.json({}, status: 503)).issue(5) }
  end

  def test_every_metron_error_can_be_rescued_together
    assert_operator Longbox::Metron::RateLimited, :<, Longbox::Metron::Error
    assert_operator Longbox::Metron::NotFound, :<, Longbox::Metron::Error
  end

  def test_needs_a_username_and_password
    assert_raises(ArgumentError) { Longbox::Metron::Client.new(username: "", password: "x") }
  end
end
