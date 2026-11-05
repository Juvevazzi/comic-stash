require_relative "test_helper"

class RunTest < Minitest::Test
  def run_of(released, owned) = Longbox::Run.new(released: released, owned: owned)

  def test_counts_what_you_own_and_what_is_missing
    run = run_of(1..24, (1..24).to_a - [ 7, 19 ])
    assert_equal 24, run.total
    assert_equal 22, run.owned_count
    assert_equal %w[7 19], run.missing.map(&:to_s)
    assert_equal 2, run.missing_count
  end

  def test_joins_neighbouring_gaps_into_a_range
    run = run_of(1..12, [ 1, 2, 3, 5, 9, 10, 12 ])
    assert_equal [ "#4", "#6–8", "#11" ], run.gaps
  end

  def test_a_gap_at_the_start_or_end_of_the_run
    assert_equal [ "#1–2", "#5" ], run_of(1..5, [ 3, 4 ]).gaps
  end

  def test_neighbours_are_next_to_each_other_in_the_run
    # This series skipped #3, so #2 and #4 are neighbours.
    assert_equal [ "#2–4" ], run_of(%w[1 2 4 5], %w[1 5]).gaps
  end

  def test_ignores_owned_issues_outside_the_run
    run = run_of(1..3, [ 1, 2, 3, 99 ])
    assert_equal 3, run.owned_count
    assert run.complete?
  end

  def test_percent_rounds_down
    assert_equal 91, run_of(1..12, 1..11).percent
    assert_equal 0, run_of([], []).percent
  end

  def test_an_empty_run_is_not_complete
    refute run_of([], []).complete?
  end

  def test_closest_puts_the_fewest_missing_first_and_skips_finished_and_unstarted_runs
    nearly = run_of(1..24, (1..24).to_a - [ 7 ])
    halfway = run_of(1..10, 1..5)
    done = run_of(1..3, 1..3)
    unstarted = run_of(1..8, [])
    assert_equal [ nearly, halfway ], Longbox::Run.closest([ halfway, done, unstarted, nearly ])
  end
end
