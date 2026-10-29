# A user's comics. index = View comics, show = View issue, new = Add comics.

class ComicsController < ApplicationController
  def index
  end

  def show
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

  # "Add in bulk": an issue range, a pasted list or a CSV file.
  def bulk
    redirect_to new_comic_path, notice: "Added. Your comics are in your collection."
  end

  # "Undo" in Added just now.
  def destroy
    redirect_to new_comic_path, notice: "Removed from your collection."
  end
end
