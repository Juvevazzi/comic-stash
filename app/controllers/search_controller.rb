# Search results (wireframe: SERP). The navbar search box sends ?q=... here.
# The tab and the status chips travel in the URL too, so every view of the
# results has its own link. StashSearch runs the queries.
class SearchController < ApplicationController
  TABS = { "all" => "All", "series" => "Your series", "issues" => "Your issues",
           "catalogue" => "Not in your stash" }.freeze

  # How many of each the All tab shows before its "See all" link.
  PREVIEW = { "series" => 3, "issues" => 6, "catalogue" => 4 }.freeze

  def index
    @search = StashSearch.new(Stash.new(Current.user), params[:q])
    @tab = TABS.key?(params[:tab]) ? params[:tab] : "all"
    # Only the three known statuses get through, whatever the URL says.
    @statuses = Array(params[:status]) & Stash::STATUSES

    @series = @search.series
    @all_issues = @search.issues
    @issues = @statuses.any? ? @search.issues(@statuses) : @all_issues
    @catalogue = @search.catalogue

    @counts = { "series" => @series.size, "issues" => @issues.size, "catalogue" => @catalogue.size }
    @counts["all"] = @counts.values.sum
  end
end
