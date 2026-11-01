require "test_helper"

# Your profile: the page, the Profile form (with server-side checks),
# preferences, the CSV export, log out and delete account.
class ProfileTest < ActionDispatch::IntegrationTest
  test "the profile shows the summary and all five sections" do
    get profile_path
    assert_response :success
    assert_select "h1", "Your profile"
    assert_select ".cs-profile-stats dd", "412"
    %w[profile preferences notifications data account].each do |id|
      assert_select "nav[aria-label='Profile sections'] a[href=?]", "##{id}"
      assert_select "section##{id}"
    end
  end

  test "the profile form uses the authentication generator's field names" do
    get profile_path
    assert_select "form[action=?]", profile_path do
      assert_select "input[name=?][type=email]", "user[email_address]"
      assert_select "input[name=?][autocomplete=current-password]", "user[password_challenge]"
      assert_select "input[name=?][autocomplete=new-password]", "user[password]"
    end
  end

  test "valid details save and come back with a message" do
    patch profile_path, params: { user: { name: "Ricardo", email_address: "rg@example.com" } }
    assert_redirected_to profile_path
    follow_redirect!
    assert_select ".alert-success", /Your profile is up to date/
  end

  test "invalid details show the form again with the errors" do
    patch profile_path, params: { user: { name: "", email_address: "not-an-email", password: "short" } }
    assert_response :unprocessable_content
    assert_select ".alert-danger", /Nothing was saved/
    assert_select "input[name=?].is-invalid[aria-invalid=true]", "user[email_address]"
    assert_select "#email_address-error", /name@example.com/
    assert_select "#password_challenge-error"
    assert_select "#password-error"
  end

  test "preferences save and return to their section" do
    patch profile_preferences_path, params: { section: "notifications", preferences: { monthly_report: "1" } }
    assert_redirected_to profile_path(anchor: "notifications")
  end

  test "the export is a CSV of every comic" do
    get profile_export_path(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
    lines = response.body.lines
    assert_equal "Series,Issue,Title,Publisher,Cover date,Cover artist,Status\n", lines.first
    assert_equal SampleStash.all_comics.size + 1, lines.size
    assert_includes response.body, "\"Mara Quill, Theo Banks\""
  end

  test "deleting the account needs the exact phrase" do
    delete profile_path, params: { confirm: "yes please" }
    assert_redirected_to profile_path(anchor: "account")

    delete profile_path, params: { confirm: "Delete my stash" }
    assert_redirected_to login_path
  end

  test "log out goes to the log in page" do
    delete logout_path
    assert_redirected_to login_path
  end
end
