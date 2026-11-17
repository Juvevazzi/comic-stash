require "csv"

# Export CSV on your profile: every issue in your series, with your status.
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
    issues = Stash.new(Current.user).issues.includes(:series).order(:series_sort_name, :sort_number, :number)
    CSV.generate do |csv|
      csv << HEADERS
      issues.each do |issue|
        csv << [ issue.series.display_name, issue.number, issue.title, issue.publisher_name,
                 issue.cover_date&.iso8601, issue.cover_artists.join(", "), issue.stash_status ]
      end
    end
  end
end
