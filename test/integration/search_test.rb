require "test_helper"

# Search results. For "night": 1 of your series (Night Watch, from setup),
# its 7 issues (6 owned, #7 on the hunt list) and 1 catalogue series nobody
# collects yet (the Night Signal fixture): 9 results.
class SearchTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:ricardo)
    add_series "Night Watch", issues: 7, owned: (1..6).to_a, hunting: [ 7 ]
  end

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
    assert_select ".cs-page-header", /9 results/
    assert_select "nav[aria-label='Result types'] a[aria-current=page]", /All\s+9/
    assert_select "section[aria-labelledby=results-series] .cs-result-card", 1
    assert_select "section[aria-labelledby=results-issues] table tbody tr", 6
    assert_select "section[aria-labelledby=results-issues] a[href=?]", search_path(q: "night", tab: "issues"), text: "See all 7"
    assert_select "section[aria-labelledby=results-catalogue] .cs-result-card", 1
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
    assert_select "table tbody tr", 6
    assert_select "#results-issues", /6 of 7/
    assert_select "input#status-owned[checked]"

    get search_path(q: "night", tab: "issues", status: [ "hunting" ])
    assert_select "table tbody tr", 1
  end

  test "an issue number, a series and number, or a creator finds the issue" do
    get search_path(q: "#7", tab: "issues")
    assert_select "table tbody tr", 1
    assert_select "table tbody tr", /Night Watch/

    get search_path(q: "paper moons #3", tab: "issues")
    assert_select "table tbody tr", 1

    get search_path(q: "kit hale", tab: "issues")
    assert_select "table tbody tr", 1
    assert_select "table tbody tr", /Paper Moons 1/
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

  test "a % in the search is a character, not a wildcard" do
    get search_path(q: "%")
    assert_select ".cs-empty", /No matches/
  end

  test "an unknown tab or status falls back safely" do
    get search_path(q: "night", tab: "drop table", status: [ "stolen" ])
    assert_response :success
    assert_select "nav[aria-label='Result types'] a[aria-current=page]", /All/
    assert_select "section[aria-labelledby=results-issues] table tbody tr", 6
  end
end
