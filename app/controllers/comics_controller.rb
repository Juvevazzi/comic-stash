# A user's comics. index = View comics, show = View issue, new = Add comics.
# Front-end stage: index filters the SampleStash list (see SampleTable);
# create, update, bulk and destroy only redirect back with a message.
class ComicsController < ApplicationController
  include SampleTable

  PER_PAGE = 8

  FILTERS = {
    series: ->(comic, value) { comic.series == value },
    issue: ->(comic, value) { comic.issue.to_s == value.delete_prefix("#").strip },
    title: ->(comic, value) { comic.title.downcase.include?(value.downcase.strip) },
    publisher: ->(comic, value) { comic.publisher == value },
    year: ->(comic, value) { comic.cover_date.year.to_s == value },
    description: ->(comic, value) { comic.description.downcase.include?(value.downcase.strip) },
    artist: ->(comic, value) { comic.artists.downcase.include?(value.downcase.strip) },
    missing: ->(comic, value) { comic.missing == (value == "yes") }
  }.freeze

  SORTS = {
    "series" => ->(comic) { [ comic.series.downcase, comic.issue ] }, # then by issue within a series
    "issue" => ->(comic) { comic.issue },
    "title" => ->(comic) { comic.title.downcase },
    "publisher" => ->(comic) { comic.publisher.downcase },
    "cover_date" => ->(comic) { comic.cover_date },
    "artists" => ->(comic) { comic.artists.downcase },
    "missing" => ->(comic) { comic.missing ? 0 : 1 } # missing first when ascending
  }.freeze

  def index
    all = SampleStash.comics_list
    sample_table(all, filters: FILTERS, sorts: SORTS, default_sort: "series", per_page: PER_PAGE)

    @options = {
      series: all.map(&:series).uniq.sort,
      publisher: all.map(&:publisher).uniq.sort,
      year: all.map { |comic| comic.cover_date.year }.uniq.sort.reverse,
      missing: [ [ "Yes", "yes" ], [ "No", "no" ] ]
    }
  end

  # View issue. With the models this becomes current_user.comics.find(params[:id]).
  def show
    @issue = SampleStash.issue(params[:id])
  end

  # Add comics page: the one-comic form, "Added just now" and bulk add.
  def new
    @series_options = SampleStash.series_options
    @just_added = SampleStash.just_added
  end

  # "Add comic". params.expect only lets the three named fields through
  # (strong parameters), which is what the real version will save.
  def create
    comic = params.expect(comic: [ :series_name, :issue_number, :barcode ])
    redirect_to new_comic_path(series: comic[:series_name]),
                notice: "Added. #{comic[:series_name]} ##{comic[:issue_number]} is in your collection."
  end

  # "Got it" and "Remove from collection" on View issue. Both change one thing,
  # whether you own this comic, so they share the RESTful update action.
  def update
    issue = SampleStash.issue(params[:id])
    owned = params.expect(comic: [ :owned ])[:owned] == "true"
    label = "#{issue.series} ##{issue.issue}"
    redirect_to comic_path(issue.id),
                notice: owned ? "Got it. #{label} is in your stash." : "Removed. #{label} is back on your gaps."
  end

  # "Add in bulk": an issue range, a pasted list or a CSV file.
  def bulk
    redirect_to new_comic_path, notice: "Added. Your comics are in your collection."
  end

  # "Undo" in Added just now.
  def destroy
    redirect_to new_comic_path, notice: "Removed from your collection."
  end
end
