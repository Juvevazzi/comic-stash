require "test_helper"

# View series and View comics: filters, sort and paging all come from the
# URL, so each test just requests a URL and checks the table it gets back.
class SeriesAndComicsTest < ActionDispatch::IntegrationTest
  test "series table shows the first page, sorted by name" do
    get series_index_path
    assert_response :success
    assert_select "table tbody tr", SeriesController::PER_PAGE
    assert_select "th[aria-sort=ascending]", /Series name/
    assert_select "table tbody tr:first-child th", "Ash and Anchor"
    assert_select "nav[aria-label=Pages] [aria-current=page]", "1"
  end

  test "filters and sort travel in the URL" do
    get series_index_path(ended: "present", sort: "began", direction: "desc")
    assert_select "table tbody tr", 5
    assert_select "table tbody tr:first-child th", "The Long Box Kids"
    assert_select ".cs-table-toolbar", /Showing 5 of 12 series/
    assert_select ".cs-table-toolbar", /1 filter on/
    assert_select "select[name=ended] option[selected]", "Present"
  end

  test "unknown sort and page values fall back safely" do
    get series_index_path(sort: "drop table", page: "999")
    assert_response :success
    assert_select "th[aria-sort=ascending]", /Series name/
    assert_select "nav[aria-label=Pages] [aria-current=page]", "2"
  end

  test "View comics on a series row filters the comics list" do
    get series_index_path
    assert_select "a[href=?]", comics_path(series: "Iron Tide")

    get comics_path(series: "Iron Tide")
    assert_select "table tbody tr", 3
    assert_select "table tbody tr.is-missing", 2
  end

  test "a filter with no matches shows the empty state" do
    get comics_path(title: "zzz")
    assert_response :success
    assert_select ".cs-empty", minimum: 1
  end
end
