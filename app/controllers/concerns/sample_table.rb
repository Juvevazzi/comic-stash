# Filters, sorts and pages an in-memory list from the URL's query string
# (?name=moon&sort=began&direction=desc&page=2), for the front-end stage.
# Each controller passes in its own rules as lambdas. With the models this
# becomes Model.where(...).order(...) plus a pagination gem, and this
# concern can be deleted.
module SampleTable
  extend ActiveSupport::Concern

  private

  # Sets @filters, @sort, @direction, @total and @page for the view.
  def sample_table(rows, filters:, sorts:, default_sort:, per_page:)
    @filters = params.permit(*filters.keys).to_h.compact_blank.symbolize_keys
    @sort = sorts.key?(params[:sort]) ? params[:sort] : default_sort
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    @total = rows.size

    shown = rows.select { |row| @filters.all? { |key, value| filters.fetch(key).call(row, value) } }
    shown = shown.sort_by(&sorts.fetch(@sort))
    shown.reverse! if @direction == "desc"
    @page = SamplePage.new(shown, page: params[:page], per: per_page)
  end
end
