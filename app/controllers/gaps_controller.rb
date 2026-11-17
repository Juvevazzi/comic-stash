# Find the gaps (wireframe: Find the gaps). Every missing issue, grouped by
# series, from Stash#gap_groups. Search, the two switches and the sort
# travel in the URL like the table pages, so a filtered view can be
# bookmarked or shared. Your gaps are a short list, so the search and
# switches narrow it in Ruby once it's loaded.
class GapsController < ApplicationController
  # Sort name in the URL => the value to sort the series by.
  SORTS = {
    "closest" => ->(group) { [ group.issues.size, group.series.sort_name ] }, # fewest missing first
    "most" => ->(group) { [ -group.issues.size, group.series.sort_name ] }, # most missing first
    "az" => ->(group) { group.series.sort_name }
  }.freeze

  helper_method :new_release?

  def index
    groups = Stash.new(Current.user).gap_groups
    issues = groups.flat_map(&:issues)

    @total_missing = issues.size
    @series_count = groups.size
    @hunt_count = issues.count(&:hunting?)
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
    found = term.empty? || group.series.name.downcase.include?(term) ||
            issue.number.downcase == term || issue.title.to_s.downcase.include?(term)

    found && (!@hunt_only || issue.hunting?) && (!@new_only || new_release?(issue))
  end

  # "New" means out since the start of last month.
  def new_release?(issue)
    issue.released_on >= Date.current.prev_month.beginning_of_month
  end
end
