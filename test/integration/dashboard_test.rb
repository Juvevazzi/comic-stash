require "test_helper"

# The dashboard renders every section of its wireframe from the controller's data.
class DashboardTest < ActionDispatch::IntegrationTest
  test "shows every section from the wireframe" do
    get dashboard_path
    assert_response :success
    assert_select "h2", "Jump in"
    assert_select ".cs-action-card", 4
    assert_select "#insights .cs-stat", 4
    assert_select "#hunt .cs-row-list > li", SampleStash.closest_runs.size
    assert_select "h2", "New in your series"
    assert_select "button[data-controller=hunt-button]", SampleStash.releases.size
  end

  test "run rows show progress and the missing issues" do
    get dashboard_path
    assert_select "#hunt .progress[aria-label=?]", "22 of 24 owned"
    assert_select "#hunt .cs-status-missing", "#7"
  end

  test "an issue already on the hunt list starts pressed" do
    get dashboard_path
    assert_select "button[data-hunt-button-on-value=true][aria-pressed=true]", 1
  end
end
