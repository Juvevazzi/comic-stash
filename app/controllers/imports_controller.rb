# Import from Metron. new searches Metron for a series while you wait (one
# request); create queues ImportSeriesJob, so the import itself, with all its
# issues, never holds up a page.
class ImportsController < ApplicationController
  def new
    @q = params[:q].to_s.strip
    @results = []
    return if @q.empty?

    @results = MetronImport.client.search_series(@q).first(10)
    @imported = Series.where(metron_id: @results.pluck("id")).pluck(:metron_id)
  rescue Longbox::Metron::Error
    @results = []
    flash.now[:alert] = "Metron isn't answering right now. Try again in a minute."
  end

  def create
    ImportSeriesJob.perform_later(params.expect(:metron_id).to_i)
    redirect_to new_import_path,
                notice: "Importing from Metron. In a minute or two it'll be in the catalogue, ready to add on Add comics."
  end
end
