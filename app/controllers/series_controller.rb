# Your series (wireframe: View series). Filters, sort and page all travel in
# the URL, so any view of the table can be bookmarked, shared or reloaded,
# and it works without JavaScript. The database does the filtering, sorting
# and paging (TableQuery), on Stash#series and the counts it works out.
class SeriesController < ApplicationController
  include TableQuery

  PER_PAGE = 8

  # Filter name in the URL => how it narrows the query.
  FILTERS = {
    name: ->(rows, value) { rows.where("series.name ILIKE ?", TableQuery.contains(value)) },
    began: ->(rows, value) { rows.where(year_began: value) },
    ended: ->(rows, value) { rows.where(year_end: value == "present" ? nil : value) },
    publisher: ->(rows, value) { rows.where("publisher_name = ?", value) },
    series_type: ->(rows, value) { rows.where(series_type: value) },
    status: ->(rows, value) { rows.where(status: value) },
    min_issues: ->(rows, value) { rows.where("released_count >= ?", value.to_i) },
    missing: ->(rows, value) { rows.where(value == "gaps" ? "missing_count > 0" : "missing_count = 0") }
  }.freeze

  # Sort name in the URL => the column to ORDER BY.
  SORTS = {
    "name" => "sort_name", "began" => "year_began",
    "ended" => "year_end", # still running (NULL) sorts after every end year
    "publisher" => "publisher_name", "series_type" => "series_type", "status" => "status",
    "issue_count" => "released_count", "missing" => "missing_count"
  }.freeze

  def index
    all = Stash.new(Current.user).series
    table_query(all, filters: FILTERS, sorts: SORTS, default_sort: "name", then_by: "sort_name, id", per_page: PER_PAGE)

    # Choices for the dropdown filters, taken from your series.
    @options = {
      began: values(all, :year_began).sort.reverse,
      ended: [ [ "Present", "present" ] ] + values(all, :year_end).sort.reverse,
      publisher: values(all, :publisher_name).sort,
      series_type: values(all, :series_type).sort,
      status: values(all, :status).sort,
      missing: [ [ "Has gaps", "gaps" ], [ "Complete", "complete" ] ]
    }
  end

  private

  # The different values in one column, without blanks.
  def values(rows, column) = rows.distinct.pluck(column).compact
end
