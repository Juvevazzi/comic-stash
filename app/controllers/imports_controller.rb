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
    ImportSeriesJob.perform_later(params.expect(:metron_id).to_i)
    # Back to the same search, so the series shows as "In the catalogue" with an Add link.
    redirect_to new_import_path(q: params[:q]),
                notice: "Importing from Metron. It takes a few seconds: reload this page to add it."
  end
end
