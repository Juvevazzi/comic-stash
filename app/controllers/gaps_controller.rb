# Find the gaps (wireframe: Find the gaps). Every missing issue, grouped by
# series. Search, the two switches and the sort travel in the URL like the
# step 11 lists, so a filtered view can be bookmarked or shared.
class GapsController < ApplicationController
  # "New releases" means a cover date from here on. The sample data is fixed
  # in time; with real data this becomes 2.months.ago.beginning_of_month.
  NEW_SINCE = Date.new(2026, 9, 1)

  # Sort name in the URL => the value to sort the series by.
  SORTS = {
    "closest" => ->(group) { [ group.issues.size, group.name ] }, # fewest missing first
    "most" => ->(group) { [ -group.issues.size, group.name ] }, # most missing first
    "az" => ->(group) { group.name }
  }.freeze

  def index
    groups = SampleStash.gap_groups
    issues = groups.flat_map(&:issues)

    @total_missing = issues.size
    @series_count = groups.size
    @hunt_count = issues.count(&:hunting)
    @new_count = issues.count { |issue| new_release?(issue) }

    @q = params[:q].to_s.strip
    @hunt_only = params[:hunt] == "1"
    @new_only = params[:new] == "1"
    @sort = SORTS.key?(params[:sort]) ? params[:sort] : "closest"
    @filtering = @q.present? || @hunt_only || @new_only

    # [group, the issues to show] for every series with something to show.
    @groups = groups.sort_by(&SORTS.fetch(@sort)).filter_map do |group|
      shown = group.issues.select { |issue| show?(group, issue) }
      [ group, shown ] if shown.any?
    end
  end

  private

  # Search matches the series name, an issue number ("12" or "#12") or a
  # word in the title; then the two switches narrow it further.
  def show?(group, issue)
    term = @q.downcase.delete_prefix("#")
    found = term.empty? || group.name.downcase.include?(term) ||
            issue.issue.to_s == term || issue.title.downcase.include?(term)

    found && (!@hunt_only || issue.hunting) && (!@new_only || new_release?(issue))
  end

  def new_release?(issue)
    issue.cover_date >= NEW_SINCE
  end
end
