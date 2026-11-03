require "test_helper"

# Accounts from the outside: the login wall, sign up, log in, keep me
# logged in, log out and the password reset email.
class AuthenticationTest < ActionDispatch::IntegrationTest
  test "app pages ask you to log in, then take you where you were going" do
    get gaps_path
    assert_redirected_to login_path

    post login_path, params: { email_address: "rg@example.com", password: "password1" }
    assert_redirected_to gaps_url
  end

  test "public pages need no account" do
    [ help_path, terms_path, privacy_path, login_path, signup_path, forgot_password_path ].each do |path|
      get path
      assert_response :success, "#{path} should be public"
    end
  end

  test "a wrong password shows the form again with the email kept" do
    post login_path, params: { email_address: "rg@example.com", password: "not-it-1" }
    assert_response :unprocessable_content
    assert_select ".alert", /don't match/
    assert_select "input[name=email_address][value=?]", "rg@example.com"
  end

  test "keep me logged in sets a lasting cookie, otherwise it ends with the browser" do
    post login_path, params: { email_address: "rg@example.com", password: "password1", remember_me: "1" }
    assert_match(/expires=/i, session_cookie)

    delete logout_path
    post login_path, params: { email_address: "rg@example.com", password: "password1", remember_me: "0" }
    assert_no_match(/expires=/i, session_cookie)
  end

  test "signing up creates the account and logs you in" do
    assert_difference("User.count") do
      post signup_path, params: { user: { name: "Juno Vale", email_address: " Juno@Example.com",
                                          password: "comics123", terms_accepted: "1" } }
    end
    assert_redirected_to dashboard_path
    assert_equal "juno@example.com", User.last.email_address

    follow_redirect!
    assert_response :success
  end

  test "sign up checks every field on the server" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: { name: "", email_address: "RG@example.com",
                                          password: "short", terms_accepted: "0" } }
    end
    assert_response :unprocessable_content
    assert_select "#name-error"
    assert_select "#email_address-error", /already an account/
    assert_select "#password-error", /at least 8 characters/
    assert_select "#terms_accepted-error"
    assert_select "input[name=?][value=?]", "user[email_address]", "RG@example.com"
  end

  test "log out ends the session" do
    sign_in_as users(:ricardo)
    delete logout_path
    assert_redirected_to login_path

    get dashboard_path
    assert_redirected_to login_path
  end

  test "forgot password emails a link that sets a new password, once" do
    assert_enqueued_emails 1 do
      post forgot_password_path, params: { email: "RG@example.com" }
    end
    follow_redirect!
    assert_select "h1", "Check your email"

    token = users(:ricardo).password_reset_token
    get edit_password_path(token)
    assert_response :success

    put password_path(token), params: { password: "newpass99", password_confirmation: "newpass99" }
    assert_redirected_to login_path

    post login_path, params: { email_address: "rg@example.com", password: "newpass99" }
    assert_redirected_to dashboard_url

    # The password changed, so the same link no longer works.
    get edit_password_path(token)
    assert_redirected_to forgot_password_path
  end

  test "an unknown email gets the same page and no email" do
    assert_no_enqueued_emails do
      post forgot_password_path, params: { email: "nobody@example.com" }
    end
    follow_redirect!
    assert_select "h1", "Check your email"
  end

  test "new passwords that don't match are shown again with a message" do
    token = users(:ricardo).password_reset_token
    put password_path(token), params: { password: "newpass99", password_confirmation: "newpass98" }
    assert_response :unprocessable_content
    assert_select "#password_confirmation-error", /don't match/
  end

  private

  # The Set-Cookie line for the login cookie in the last response.
  def session_cookie
    Array(response.headers["set-cookie"]).join("\n").lines.grep(/\Asession_id=/).first.to_s
  end
end
