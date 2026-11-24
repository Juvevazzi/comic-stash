# One user's stash, seen against the shared catalogue. Every reading page asks
# it the same few questions: which series do I collect, how complete are they,
# which issues am I missing, and what's new? The database does the counting;
# the Longbox gem does the run maths (gaps, streaks, closest to complete).
#
#   stash = Stash.new(Current.user)
#   stash.series.where("missing_count > 0")   # your series with gaps
#   stash.stats.comic_count                   # how many comics you own
class Stash
  STATUSES = %w[owned missing hunting].freeze

  Stats = Data.define(:series_count, :complete_runs, :comic_count, :added_this_month,
                      :streak, :streak_series, :missing_count, :series_with_gaps, :hunting_count)
  ClosestRun = Data.define(:series, :run)
  GapGroup = Data.define(:series, :issues)

  attr_reader :user, :today

  def initialize(user, today: Date.current)
    @user = user
    @today = today
  end

  # Every series with at least one issue in your stash. Each one comes with
  # numbers the database works out for it:
  #   publisher_name, released_count (issues out so far), missing_count
  #   (released issues you don't own), hunting_count and added_at (when you
  #   last added one of its issues).
  # It's wrapped as a subquery, so pages can filter and sort on those numbers.
  def series
    Series.from(series_with_counts, :series)
  end

  # Every issue of your series that's out, or already in your stash, with
  # stash_status ("owned", "hunting" or "missing"), plus series_name,
  # series_sort_name and publisher_name to sort and filter by.
  def issues
    released_or_mine = issues_with_status
      .where("COALESCE(issues.store_date, issues.cover_date) <= ? OR mine.id IS NOT NULL", today)
    Issue.from(released_or_mine, :issues)
  end

  # Released issues you don't own, hunted or not: what Find the gaps lists.
  def missing_issues
    issues.where("stash_status <> 'owned'").merge(Issue.released(today))
  end

  # Issues of your series you don't own yet that came out in the last month
  # or are due in the next two, newest first: "New in your series".
  def releases(limit: 3)
    window = issues_with_status
      .where("COALESCE(issues.store_date, issues.cover_date) BETWEEN ? AND ?", today - 1.month, today + 2.months)
      .where("mine.status IS DISTINCT FROM ?", CollectionItem.statuses[:owned])
    Issue.from(window, :issues).includes(:series)
         .order(Arel.sql("COALESCE(store_date, cover_date) DESC"), :id).limit(limit)
  end

  # A Longbox::Run for every series you collect, keyed by series. Three
  # queries in all, however many series you have.
  def runs
    @runs ||= begin
      collected = user.collected_series.with_cover.to_a
      released = numbers_by_series(Issue.released(today).where(series: collected))
      owned = numbers_by_series(user.owned_issues)
      collected.index_with do |series|
        Longbox::Run.new(released: released.fetch(series.id, []), owned: owned.fetch(series.id, []))
      end
    end
  end

  # The runs you're closest to finishing, picked by Longbox::Run.closest.
  def closest_runs(limit: 3)
    Longbox::Run.closest(runs.values, limit: limit).map do |run|
      ClosestRun.new(series: runs.key(run), run: run)
    end
  end

  # The headline numbers for the dashboard and your profile.
  def stats
    @stats ||= begin
      streak_series, streak_run = runs.max_by { |_series, run| run.streak }
      Stats.new(
        series_count: runs.size,
        complete_runs: runs.values.count(&:complete?),
        comic_count: user.owned_issues.count,
        added_this_month: user.collection_items.owned.where(created_at: today.beginning_of_month..).count,
        streak: streak_run&.streak.to_i,
        streak_series: streak_series,
        missing_count: runs.values.sum(&:missing_count),
        series_with_gaps: runs.values.count { |run| run.missing_count.positive? },
        hunting_count: user.collection_items.hunting.count
      )
    end
  end

  # Find the gaps: one group per series with missing issues, each group's
  # issues in number order. Two queries.
  def gap_groups
    missing = missing_issues.order(:sort_number, :number).to_a
    counted = series.where(id: missing.map(&:series_id).uniq).index_by(&:id)
    missing.group_by(&:series_id).map do |series_id, issues|
      GapGroup.new(series: counted.fetch(series_id), issues: issues)
    end
  end

  private

  def series_with_counts
    Series.where(id: user.issues.select(:series_id))
          .joins("LEFT JOIN publishers ON publishers.id = series.publisher_id")
          .select("series.*", "publishers.name AS publisher_name", Series::COVER_SELECT, sql(<<~SQL))
            (SELECT COUNT(*) FROM issues i
              WHERE i.series_id = series.id AND COALESCE(i.store_date, i.cover_date) <= :today) AS released_count,
            (SELECT COUNT(*) FROM issues i
              WHERE i.series_id = series.id AND COALESCE(i.store_date, i.cover_date) <= :today
                AND NOT EXISTS (SELECT 1 FROM collection_items ci
                                 WHERE ci.issue_id = i.id AND ci.user_id = :user AND ci.status = :owned)) AS missing_count,
            (SELECT COUNT(*) FROM collection_items ci JOIN issues i ON i.id = ci.issue_id
              WHERE i.series_id = series.id AND ci.user_id = :user AND ci.status = :hunting) AS hunting_count,
            (SELECT MAX(ci.created_at) FROM collection_items ci JOIN issues i ON i.id = ci.issue_id
              WHERE i.series_id = series.id AND ci.user_id = :user) AS added_at
          SQL
  end

  # Issues of your series with your collection item joined on as "mine"
  # (LEFT JOIN, so issues you don't have come back too, with mine.* empty).
  def issues_with_status
    Issue.joins(:series)
         .joins("LEFT JOIN publishers ON publishers.id = series.publisher_id")
         .joins(sql("LEFT JOIN collection_items mine ON mine.issue_id = issues.id AND mine.user_id = :user"))
         .where(series_id: user.issues.select(:series_id))
         .select("issues.*", "series.name AS series_name", "series.sort_name AS series_sort_name",
                 "publishers.name AS publisher_name", "mine.created_at AS added_at",
                 sql("CASE mine.status WHEN :owned THEN 'owned' WHEN :hunting THEN 'hunting' ELSE 'missing' END AS stash_status"))
  end

  # Fills in :today, :user, :owned and :hunting, quoted safely.
  def sql(fragment)
    ActiveRecord::Base.sanitize_sql_array([ fragment, { today: today, user: user.id,
                                                        owned: CollectionItem.statuses[:owned],
                                                        hunting: CollectionItem.statuses[:hunting] } ])
  end

  # { series_id => ["1", "2", ...] } from (series_id, number) pairs.
  def numbers_by_series(issues)
    issues.pluck(:series_id, :number).group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
  end
end
