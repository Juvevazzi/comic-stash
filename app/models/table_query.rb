# Filters, sorts and pages a database query from the URL's query string
# (?name=moon&sort=began&direction=desc&page=2), for View series and View
# comics. Each controller passes in its own rules: a lambda per filter that
# narrows the query, and the SQL column behind each sort. Only those keys are
# read from params, and the ORDER BY column always comes from the
# controller's list, never from the URL, so nothing typed into the URL can
# change the SQL.
module TableQuery
  extend ActiveSupport::Concern

  # "%moon%" for an ILIKE search, with any % or _ the user typed escaped.
  def self.contains(value) = "%#{ActiveRecord::Base.sanitize_sql_like(value.strip)}%"

  private

  # Sets @filters, @sort, @direction, @total and @page for the view.
  # then_by breaks ties, so rows never swap places between pages.
  def table_query(rows, filters:, sorts:, default_sort:, then_by:, per_page:)
    @filters = params.permit(*filters.keys).to_h.compact_blank.symbolize_keys
    @sort = sorts.key?(params[:sort]) ? params[:sort] : default_sort
    @direction = params[:direction] == "desc" ? "desc" : "asc"
    @total = rows.count

    shown = @filters.reduce(rows) { |query, (key, value)| filters.fetch(key).call(query, value) }
    column = Arel.sql(sorts.fetch(@sort))
    shown = shown.order(@direction == "desc" ? column.desc : column.asc, Arel.sql(then_by))
    @page = Page.new(shown, page: params[:page], per: per_page)
  end
end
