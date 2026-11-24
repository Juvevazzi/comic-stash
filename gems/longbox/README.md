# Longbox

The comic-collecting logic behind Comic Stash, as a Ruby gem with no Rails dependency.

## Runs and gaps

```ruby
run = Longbox::Run.new(released: 1..12, owned: [1, 2, 3, 5, 9, 10, 12])
run.owned_count  # => 7
run.missing_count  # => 5
run.gaps  # => ["#4", "#6–8", "#11"]
run.percent  # => 58
Longbox::Run.closest([run, other_run])  # unfinished runs, fewest missing first
```

Issue numbers are text (`"1.5"`, `"½"`) and sort like a collector expects.

## Tests

    cd gems/longbox && bundle exec rake test

## The Metron client

```ruby
client = Longbox::Metron::Client.new(token: "...")  # an API token from your Metron profile
client.search_series("Saga")  # first page of matching series
client.series(id)  # one series
client.series_issues(id)  # every issue in a series, all pages
client.issue(id)  # one issue, with credits and characters
client.rate_limit  # what's left of Metron's limits after the last request
```

Errors are all `Longbox::Metron::Error`: `AuthenticationError`, `NotFound`, `RateLimited` (with `retry_after` in seconds) and `ServerError`.

Tests never touch the network: pass `transport:` any object with `call(uri, headers)` that returns a `Longbox::Metron::Response`. See `test/fake_transport.rb`.
