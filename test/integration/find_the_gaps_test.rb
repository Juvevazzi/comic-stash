require "test_helper"

# Find the gaps: 29 missing issues across 8 series (SampleStash.gap_groups).
# Search, switches and sort come from the URL, so each test requests a URL.
class FindTheGapsTest < ActionDispatch::IntegrationTest
  test "every series with gaps, closest to complete first, the first two open" do
    get gaps_path
    assert_response :success
    assert_select ".cs-page-header", /29 issues missing across 8 series/
    assert_select "details.cs-gap-group", 8
    assert_select "details.cs-gap-group:first-of-type h2", "Static Saints"
    assert_select "details.cs-gap-group[open]", 2
  end

  test "search finds an issue number and opens what it finds" do
    get gaps_path(q: "#12")
    assert_select "details.cs-gap-group", 1
    assert_select "details.cs-gap-group[open] h2", "Iron Tide"
    assert_select "table.cs-gap-table tbody tr", 1
    assert_select ".cs-gap-note", /Showing 1 of 3/
  end

  test "the switches narrow to the hunt list and to new releases" do
    get gaps_path(hunt: "1")
    assert_select "table.cs-gap-table tbody tr", 3
    assert_select "input[name=hunt][checked]"

    get gaps_path(new: "1")
    assert_select "table.cs-gap-table tbody tr", 4
  end

  test "most missing puts Hollow Crown first" do
    get gaps_path(sort: "most")
    assert_select "details.cs-gap-group:first-of-type h2", "Hollow Crown"
  end

  test "no matches shows the empty state" do
    get gaps_path(q: "zzz")
    assert_select "details.cs-gap-group", 0
    assert_select ".cs-empty", /Nothing matches/
  end

  test "Got it comes back to the same filtered view with an Undo" do
    patch comic_path(15), params: { comic: { owned: "true" } }, headers: { "HTTP_REFERER" => gaps_url(q: "night") }
    assert_redirected_to gaps_url(q: "night")
    follow_redirect!
    assert_select ".alert", /Night Signal #49 is in your stash/
    assert_select ".alert form[action=?]", comic_path(15)
  end

  test "every missing issue opens its View issue page" do
    get comic_path(15)
    assert_response :success
    assert_select "h1", "Night Signal #49"
  end
end
