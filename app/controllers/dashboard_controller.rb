# Your dashboard (wireframe: User dashboard). Every number and list comes
# from your stash: Stash for the counts and runs, plus your newest items.
class DashboardController < ApplicationController
  def show
    stash = Stash.new(Current.user)
    @stats = stash.stats
    @closest_runs = stash.closest_runs
    @releases = stash.releases.to_a
    @recent_series = stash.series.order(Arel.sql("added_at DESC")).limit(3)
    @recent_comics = Current.user.collection_items.owned.includes(issue: :series).order(created_at: :desc).limit(3)
  end
end
