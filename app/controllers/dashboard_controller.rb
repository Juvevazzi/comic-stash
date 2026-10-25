# A user's dashboard. show = View dashboard.
# TODO: front-end only first then add back-end functionality. Actions only render views for now.

class DashboardController < ApplicationController
  def show
    @stats = SampleStash.stats
    @closest_runs = SampleStash.closest_runs
    @releases = SampleStash.releases
    @recent_series = SampleStash.recent_series
    @recent_comics = SampleStash.recent_comics
  end
end
