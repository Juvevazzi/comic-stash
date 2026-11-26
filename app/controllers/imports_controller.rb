# Import from Metron. new searches Metron for a series while you wait (one
# request); create queues ImportSeriesJob, so the import itself, with all its
# issues, never holds up a page.
class ImportsController < ApplicationController
  rate_limit to: 10, within: 1.minute, only: :new, by: -> { Current.user.id },
           with: -> { redirect_to new_import_path, alert: "Too many searches. Wait a minute and try again." }
  rate_limit to: 5, within: 1.hour, only: :create, by: -> { Current.user.id },
            with: -> { redirect_to new_import_path, alert: "You've queued 5 imports this hour. Try again later." }
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
    if Series.exists?(metron_id: metron_id)
      return redirect_to new_import_path(q: params[:q]), notice: "That series is already in the catalogue."
    end

    ImportSeriesJob.perform_later(metron_id)
    redirect_to new_import_path(q: params[:q]),
                notice: "Importing from Metron. It takes a few seconds: reload this page to add it."
  end
end
