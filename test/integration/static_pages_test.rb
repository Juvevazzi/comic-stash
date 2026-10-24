require "test_helper"

# Tests for the front-end stage: every wireframe page renders with the right layout, title and heading. Once a page is wired to real models these stay and grow into proper controller tests.
class StaticPagesTest < ActionDispatch::IntegrationTest
  APP_PAGES = {
    "/dashboard" => "Welcome back",
    "/comics" => "Your comics",
    "/comics/new" => "Add comics",
    "/comics/1" => "Issue details",
    "/series" => "Your series",
    "/gaps" => "Find the gaps",
    "/search" => "Search",
    "/profile" => "Your profile"
  }.freeze

  # One generated test per page, so a failure names the page that broke.
  APP_PAGES.each do |path, heading|
    test "#{path} renders inside the app shell" do
      get path
      assert_response :success
      assert_select "h1", heading
      assert_select "header.cs-navbar"
      assert_select "nav.cs-bottom-nav[aria-label=Main]"
    end
  end

  # The domain should redirect to the dashboard.
  test "the bare domain redirects to the dashboard" do
    get "/"
    assert_redirected_to "/dashboard"
  end

  # The navbar should mark the current section.
  test "navbar marks the current section" do
    get "/series"
    assert_select "header.cs-navbar a.active[aria-current=page]", "Series"
  end

  # The log in page should use the auth layout and the generator's field names.
  test "log in page uses the auth layout and the generator's field names" do
    get "/login"
    assert_response :success
    assert_select "title", "Log in · Comic Stash"
    assert_select "form[action=?][method=post]", login_path do
      assert_select "input[type=email][name=email_address]"
      assert_select "input[type=password][name=password][autocomplete=current-password]"
    end
    assert_select "a[href=?]", signup_path
    assert_select "header.cs-navbar", count: 0
  end

  # The sign up page should use the auth layout and nest fields under user, and list the password rules.
  test "sign up page nests fields under user and lists password rules" do
    get "/signup"
    assert_response :success
    assert_select "form[action=?][method=post]", signup_path
    assert_select "input[name=?]", "user[name]"
    assert_select "input[name=?]", "user[email_address]"
    assert_select "input[name=?][aria-describedby=password-rules]", "user[password]"
    assert_select "#password-rules li[data-pattern]", 2
  end

  # The forgot password page should use the auth layout and nest fields under user.
  test "log in stub goes to the dashboard" do
    post login_path, params: { email_address: "rg@example.com", password: "secret123" }
    assert_redirected_to dashboard_path
  end

  # The forgot password page should use the auth layout and nest fields under user.
  test "forgot password shows the sent state with the typed email" do
    get forgot_password_path
    assert_select "h1", "Reset your password"

    post forgot_password_path, params: { email: "rg@example.com" }
    assert_response :success
    assert_select "h1", "Check your email"
    assert_select "strong", "rg@example.com"
  end

  # The help, terms and privacy pages should use the public layout.
  %w[/help /terms /privacy].each do |path|
    test "#{path} renders with the public layout" do
      get path
      assert_response :success
      assert_select "header.cs-public-header"
    end
  end
end
