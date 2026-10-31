require "test_helper"

# Search results. "night" matches 1 of your series, 7 of your issues
# (Night Signal #48 to #53 and Wolf Hours #9 "The Long Night") and
# 3 catalogue series: 11 results.
class SearchTest < ActionDispatch::IntegrationTest
  test "with no search term the page asks for one" do
    get search_path
    assert_response :success
    assert_select "h1", "Search your stash"
    assert_select ".cs-search-prompt"
    assert_select ".cs-result-section", 0
  end

  test "the All tab previews each section and links to the rest" do
    get search_path(q: "night")
    assert_select "h1", "Results for “night”"
    assert_select ".cs-page-header", /11 results/
    assert_select "nav[aria-label='Result types'] a[aria-current=page]", /All\s+11/
    assert_select "section[aria-labelledby=results-series] .cs-result-card", 1
    assert_select "section[aria-labelledby=results-issues] table tbody tr", 6
    assert_select "section[aria-labelledby=results-issues] a[href=?]", search_path(q: "night", tab: "issues"), text: "See all 7"
    assert_select "section[aria-labelledby=results-catalogue] .cs-result-card", 3
  end

  test "matched words are highlighted" do
    get search_path(q: "night")
    assert_select "section[aria-labelledby=results-series] h3 mark", "Night"
  end

  test "a tab shows only its section, in full" do
    get search_path(q: "night", tab: "issues")
    assert_select ".cs-result-section", 1
    assert_select "table tbody tr", 7
  end

  test "status chips narrow Your issues and travel in the URL" do
    get search_path(q: "night", tab: "issues", status: [ "owned" ])
    assert_select "table tbody tr", 1
    assert_select "#results-issues", /1 of 7/
    assert_select "input#status-owned[checked]"
  end

  test "an issue number finds that issue" do
    get search_path(q: "#12", tab: "issues")
    assert_select "table tbody tr", 1
    assert_select "table tbody tr", /Iron Tide/
  end

  test "no matches offers Add comics" do
    get search_path(q: "zzz")
    assert_select ".cs-empty", /No matches for “zzz”/
    assert_select ".cs-empty a[href=?]", new_comic_path
  end

  test "the search term is escaped, never run as HTML" do
    get search_path(q: "<b>bold</b>")
    assert_response :success
    assert_select "main b", 0
    assert_select "h1", "Results for “<b>bold</b>”"
  end

  test "an unknown tab or status falls back safely" do
    get search_path(q: "night", tab: "drop table", status: [ "stolen" ])
    assert_response :success
    assert_select "nav[aria-label='Result types'] a[aria-current=page]", /All/
    assert_select "section[aria-labelledby=results-issues] table tbody tr", 6
  end
end
