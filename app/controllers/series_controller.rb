# Your series (wireframe: View series). Filters, sort and page all travel in
# the URL, so any view of the table can be bookmarked, shared or reloaded,
# and it works without JavaScript. Front-end stage: SampleTable filters the
# SampleStash list in Ruby; with the models it becomes a database query.
class SeriesController < ApplicationController
  include SampleTable

  PER_PAGE = 8

  # Filter name in the URL => does this series pass? Only these keys are
  # read from params, so nothing else in the URL can change the query.
  FILTERS = {
    name: ->(series, value) { series.name.downcase.include?(value.downcase.strip) },
    began: ->(series, value) { series.began.to_s == value },
    ended: ->(series, value) { value == "present" ? series.ended.nil? : series.ended.to_s == value },
    publisher: ->(series, value) { series.publisher == value },
    series_type: ->(series, value) { series.series_type == value },
    status: ->(series, value) { series.status == value },
    min_issues: ->(series, value) { series.issue_count >= value.to_i },
    missing: ->(series, value) { value == "gaps" ? series.missing.positive? : series.missing.zero? }
  }.freeze

  # Sort name in the URL => the value to sort by.
  SORTS = {
    "name" => ->(series) { series.name.downcase },
    "began" => ->(series) { series.began },
    "ended" => ->(series) { series.ended || 9999 }, # still running sorts after every end year
    "publisher" => ->(series) { series.publisher.downcase },
    "series_type" => ->(series) { series.series_type.downcase },
    "status" => ->(series) { series.status.downcase },
    "issue_count" => ->(series) { series.issue_count },
    "missing" => ->(series) { series.missing }
  }.freeze

  def index
    all = SampleStash.series_list
    sample_table(all, filters: FILTERS, sorts: SORTS, default_sort: "name", per_page: PER_PAGE)

    # Choices for the dropdown filters, taken from the data itself.
    @options = {
      began: all.map(&:began).uniq.sort.reverse,
      ended: [ [ "Present", "present" ] ] + all.filter_map(&:ended).uniq.sort.reverse,
      publisher: all.map(&:publisher).uniq.sort,
      series_type: all.map(&:series_type).uniq.sort,
      status: all.map(&:status).uniq.sort,
      missing: [ [ "Has gaps", "gaps" ], [ "Complete", "complete" ] ]
    }
  end
end
