require "test_helper"

# Every page and every button that reads or changes a stash needs a
# logged-in user, and a session ended by Log out can't be used again.
class LoginWallTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "every app page sends you to log in" do
    [ dashboard_path, series_index_path, comics_path, comic_path(issues(:paper_moons_1)), new_comic_path,
      gaps_path, search_path, profile_path, profile_export_path(format: :csv), new_import_path ].each do |path|
      get path
      assert_redirected_to login_path, "#{path} should need a log-in"
    end
  end

  test "no button changes anything without a log-in" do
    assert_no_difference -> { CollectionItem.count } do
      post comics_path, params: { comic: { series_name: "Night Signal", issue_number: "2" } }
      post bulk_comics_path, params: { bulk: { source: "range", series_name: "Night Signal", from: "2", to: "4" } }
      patch comic_path(issues(:paper_moons_3)), params: { comic: { owned: "true" } }
      delete comic_path(issues(:paper_moons_1))
      post comic_hunt_path(issues(:night_signal_1))
      delete comic_hunt_path(issues(:paper_moons_3))
    end
    assert_no_enqueued_jobs { post imports_path, params: { metron_id: "501" } }
    assert_redirected_to login_path
  end

  test "the session cookie stops working after Log out" do
    sign_in_as users(:ricardo)
    copied = cookies["session_id"]
    delete logout_path

    cookies["session_id"] = copied # as if someone had copied the cookie before Log out
    get dashboard_path
    assert_redirected_to login_path
  end
end
