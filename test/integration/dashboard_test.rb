require "test_helper"

# The dashboard, from Ricardo's fixture stash: Paper Moons #1, #2 and #4
# owned, #3 on the hunt list, #5 out next month.
class DashboardTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:ricardo) }

  test "shows every section from the wireframe" do
    get dashboard_path
    assert_response :success
    assert_select "h2", "Jump in"
    assert_select ".cs-action-card", 4
    assert_select "#insights .cs-stat", 4
    assert_select "h2", "New in your series"
  end

  test "the numbers are your stash's" do
    get dashboard_path
    assert_select "#insights .cs-stat", text: /Comics in your stash\s+3\s/
    assert_select "#insights .cs-stat", text: /Issues still missing\s+1\s/
    assert_select "#insights .cs-stat", text: /Longest unbroken run\s+2\s/
  end

  test "closest to complete shows your run and its gap" do
    get dashboard_path
    assert_select "#hunt .cs-row-list > li", 1
    assert_select "#hunt .progress[aria-label=?]", "3 of 4 owned"
    assert_select "#hunt .cs-status-missing", "#3"
  end

  test "new in your series lists the upcoming issue" do
    get dashboard_path
    assert_select ".cs-status-upcoming", 1
    assert_select "button[data-controller=hunt-button]", 1
  end

  test "a new issue on your hunt list starts pressed" do
    issues(:paper_moons_3).update!(store_date: 1.week.ago.to_date)
    get dashboard_path
    assert_select "button[data-controller=hunt-button]", 2
    assert_select "button[data-hunt-button-on-value=true][aria-pressed=true]", 1
  end

  test "another collector's stash never shows on yours" do
    add_series "Ada Only", issues: 2, owned: [ 1 ], user: users(:ada)
    get dashboard_path
    assert_no_match "Ada Only", response.body
  end
end
