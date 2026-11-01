require "csv"

class ExportsController < ApplicationController
  HEADERS = [ "Series", "Issue", "Title", "Publisher", "Cover date", "Cover artist", "Status" ].freeze

  def show
    respond_to do |format|
      format.csv do
        send_data collection_csv, filename: "comic-stash-#{Date.current.iso8601}.csv", type: :csv
      end
    end
  end

  private

  def collection_csv
    CSV.generate do |csv|
      csv << HEADERS
      SampleStash.all_comics.sort_by { |comic| [ comic.series, comic.issue ] }.each do |comic|
        csv << [ comic.series, comic.issue, comic.title, comic.publisher, comic.cover_date.iso8601,
                 comic.artists, SampleSearch.status(comic) ]
      end
    end
  end
end
