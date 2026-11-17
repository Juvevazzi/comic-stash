# Builds a series straight into the test database, with a user's stash, for
# tests that need more than the fixtures. Issue n is released (issues - n + 1)
# months ago, so the last one came out a month ago.
#
#   add_series "Iron Tide", issues: 12, owned: (1..10).to_a, hunting: [ 11 ]
module StashTestHelper
  def add_series(name, issues:, owned: [], hunting: [], user: users(:ricardo), **attributes)
    Series.create!(name: name, **attributes).tap do |series|
      (1..issues).each do |number|
        issue = series.issues.create!(number: number.to_s, store_date: (issues - number + 1).months.ago.to_date)
        status = (:owned if owned.include?(number)) || (:hunting if hunting.include?(number))
        user.collection_items.create!(issue: issue, status: status) if status
      end
    end
  end
end
