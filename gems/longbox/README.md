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
