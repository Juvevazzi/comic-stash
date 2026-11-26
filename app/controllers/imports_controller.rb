# Import from Metron. new searches Metron for a series while you wait (one
# request); create queues ImportSeriesJob, so the import itself, with all its
# issues, never holds up a page.
class ImportsController < ApplicationController
  def new
    @q = params[:q].to_s.strip
    @results = []
    return if @q.empty?

    @results = MetronImport.client.search_series(@q).first(10)
    # A lookup by Metron id, so the view can link to each imported series.
    @imported = Series.where(metron_id: @results.pluck("id")).index_by(&:metron_id)
  rescue Longbox::Metron::Error
    @results = []
    flash.now[:alert] = "Metron isn't answering right now. Try again in a minute."
  end

  def create
    metron_id = params.expect(:metron_id).to_i
    series = MetronImport.new.import_series(metron_id)
    redirect_to new_import_path,
                notice: "Imported #{series.display_name}: #{series.issues.count} issues. Add them on Add comics."
  rescue Longbox::Metron::RateLimited
    redirect_to new_import_path, alert: "Metron is busy right now. Try again in a minute."
  rescue Longbox::Metron::NotFound
    redirect_to new_import_path, alert: "Metron doesn't have that series any more."
  rescue Longbox::Metron::Error, ActiveRecord::RecordInvalid => error
    Rails.logger.warn("[metron] import #{metron_id} failed: #{error.class}: #{error.message}")
    redirect_to new_import_path, alert: "That import didn't work. Try again in a minute."
  end
end
