require "test_helper"

# View series and View comics: filters, sort and paging come from the URL
# and run in the database. Ricardo collects Paper Moons (fixtures) plus
# the series made in setup: 9 series, so the series table has 2 pages.
class SeriesAndComicsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:ricardo)
    %w[Brass Cinder Dune Ember Flint Garnet Harbour].each_with_index do |name, index|
      add_series name, issues: 2, owned: [ 1 ], year_began: 2010 + index, year_end: 2012 + index
    end
    add_series "Ash and Anchor", issues: 3, owned: [ 1, 2, 3 ], year_began: 2024
  end

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
    assert_select "table tbody tr", 2
    assert_select "table tbody tr:first-child th", "Ash and Anchor"
    assert_select ".cs-table-toolbar", /Showing 2 of 9 series/
    assert_select ".cs-table-toolbar", /1 filter on/
    assert_select "select[name=ended] option[selected]", "Present"
  end

  test "the missing filter uses the database's counts" do
    get series_index_path(missing: "complete")
    assert_select "table tbody tr", 1
    assert_select "table tbody tr th", "Ash and Anchor"
    assert_select "table tbody tr", /Complete/
  end

  test "unknown sort and page values fall back safely" do
    get series_index_path(sort: "drop table", page: "999")
    assert_response :success
    assert_select "th[aria-sort=ascending]", /Series name/
    assert_select "nav[aria-label=Pages] [aria-current=page]", "2"
  end

  test "View comics on a series row filters the comics list" do
    paper_moons = series(:paper_moons)
    get series_index_path(name: "moons")
    assert_select "a[href=?]", comics_path(series: paper_moons.id)

    get comics_path(series: paper_moons.id)
    assert_select "table tbody tr", 4 # #5 isn't out yet
    assert_select "table tbody tr.is-missing", 1
  end

  test "comics filter and sort in the database" do
    get comics_path(series: series(:paper_moons).id, sort: "issue", direction: "desc")
    assert_select "table tbody tr:first-child td.cs-issue-no", "#4"

    get comics_path(artist: "kit")
    assert_select "table tbody tr", 1
    assert_select "table tbody tr th", "Paper Moons 1"
  end

  test "a filter with no matches shows the empty state" do
    get comics_path(title: "zzz")
    assert_response :success
    assert_select ".cs-empty", minimum: 1
  end

  test "another collector's series never show in yours" do
    add_series "Ada Only", issues: 2, owned: [ 1 ], user: users(:ada)
    get series_index_path(name: "ada")
    assert_select "table tbody tr", 0
  end
end
