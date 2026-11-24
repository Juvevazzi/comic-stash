require "test_helper"

# Find the gaps. Ricardo is missing Paper Moons #3 (fixtures, on his hunt
# list) and, from setup, Iron Tide #3, #11 (hunting) and #12 (out last
# month, so it's a new release): 4 issues across 2 series.
class FindTheGapsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:ricardo)
    @iron_tide = add_series "Iron Tide", issues: 12, owned: (1..12).to_a - [ 3, 11, 12 ], hunting: [ 11 ]
  end

  test "every series with gaps, closest to complete first, the first two open" do
    get gaps_path
    assert_response :success
    assert_select ".cs-page-header", /4 issues missing across 2 series/
    assert_select "details.cs-gap-group", 2
    assert_select "details.cs-gap-group:first-of-type h2", "Paper Moons Vol. 2"
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
    assert_select "table.cs-gap-table tbody tr", 2
    assert_select "input[name=hunt][checked]"

    get gaps_path(new: "1")
    assert_select "table.cs-gap-table tbody tr", 1
  end

  test "most missing puts Iron Tide first" do
    get gaps_path(sort: "most")
    assert_select "details.cs-gap-group:first-of-type h2", "Iron Tide"
  end

  test "no matches shows the empty state" do
    get gaps_path(q: "zzz")
    assert_select "details.cs-gap-group", 0
    assert_select ".cs-empty", /Nothing matches/
  end

  test "Got it comes back to the same filtered view with an Undo" do
    issue = @iron_tide.issues.find_by!(number: "12")
    patch comic_path(issue), params: { comic: { owned: "true" } }, headers: { "HTTP_REFERER" => gaps_url(q: "iron") }
    assert_redirected_to gaps_url(q: "iron")
    follow_redirect!
    assert_select ".alert", /Iron Tide #12 is in your stash/
    assert_select ".alert form[action=?]", comic_path(issue)
  end

  test "every missing issue opens its View issue page" do
    get comic_path(@iron_tide.issues.find_by!(number: "3"))
    assert_response :success
    assert_select "h1", "Iron Tide #3"
  end
end
