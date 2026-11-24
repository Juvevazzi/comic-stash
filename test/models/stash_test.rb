require "test_helper"

# Ricardo's fixture stash: Paper Moons #1, #2 and #4 owned, #3 on the hunt
# list, #5 out next month. Ada owns #1. Night Signal is in the catalogue,
# but nobody collects it.
class StashTest < ActiveSupport::TestCase
  setup { @stash = Stash.new(users(:ricardo)) }

  test "series are the ones you collect, counted by the database" do
    series = @stash.series.sole
    assert_equal series(:paper_moons), series
    assert_equal "Lantern Press", series.publisher_name
    assert_equal 4, series.released_count
    assert_equal 1, series.missing_count
    assert_equal 3, series.owned_count
    assert_equal 1, series.hunting_count
  end

  test "the database's counts agree with the Longbox gem" do
    counted = @stash.series.sole
    run = users(:ricardo).run_for(series(:paper_moons))
    assert_equal run.total, counted.released_count
    assert_equal run.missing_count, counted.missing_count
  end

  test "issues carry your status; upcoming issues you don't have are left out" do
    assert_equal [ %w[1 owned], %w[2 owned], %w[3 hunting], %w[4 owned] ],
                 @stash.issues.order(:sort_number).pluck(:number, :stash_status)
  end

  test "each user sees their own status for the same issues" do
    ada = Stash.new(users(:ada))
    assert_equal %w[owned missing missing missing], ada.issues.order(:sort_number).pluck(:stash_status)
    assert_equal 3, ada.series.sole.missing_count
  end

  test "missing issues are the released ones you don't own, hunted or not" do
    assert_equal %w[3], @stash.missing_issues.pluck(:number)
  end

  test "stats add up the whole stash" do
    stats = @stash.stats
    assert_equal 1, stats.series_count
    assert_equal 0, stats.complete_runs
    assert_equal 3, stats.comic_count
    assert_equal 1, stats.missing_count
    assert_equal 1, stats.series_with_gaps
    assert_equal 1, stats.hunting_count
    assert_equal 2, stats.streak # #1 and #2, then the gap at #3
    assert_equal series(:paper_moons), stats.streak_series
  end

  test "closest runs come from Longbox::Run.closest" do
    closest = @stash.closest_runs.sole
    assert_equal series(:paper_moons), closest.series
    assert_equal [ "#3" ], closest.run.gaps
  end

  test "releases are new or upcoming issues you don't own" do
    assert_equal [ issues(:paper_moons_5) ], @stash.releases.to_a
  end

  test "gap groups hold each series and its missing issues" do
    group = @stash.gap_groups.sole
    assert_equal series(:paper_moons), group.series
    assert_equal 3, group.series.owned_count
    assert_equal %w[3], group.issues.map(&:number)
    assert group.issues.first.hunting?
  end

  test "an empty stash has nothing to count" do
    newcomer = User.create!(name: "New Collector", email_address: "new@example.com",
                            password: "password1", terms_accepted: "1")
    stash = Stash.new(newcomer)
    assert_equal 0, stash.stats.series_count
    assert_equal 0, stash.stats.streak
    assert_nil stash.stats.streak_series
    assert_empty stash.closest_runs
    assert_empty stash.gap_groups
  end

  test "series come with their cover, from the same query" do
    issues(:paper_moons_1).update!(image_url: "https://static.metron.cloud/media/issue/pm1.jpg")
    series = @stash.series.sole
    assert series.has_attribute?(:cover_url), "cover_url should be a column of the Stash query"
    assert_equal "https://static.metron.cloud/media/issue/pm1.jpg", series.cover_url
  end
end
