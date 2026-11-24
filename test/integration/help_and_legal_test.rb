require "test_helper"

# Help (topic and search in the URL), Terms and Privacy (contents list
# matches the sections), and the branded error pages.
class HelpAndLegalTest < ActionDispatch::IntegrationTest
  test "help lists every answer with the first one open" do
    get help_path
    assert_response :success
    assert_select "h1", "How can we help?"
    assert_select ".cs-faq details", PagesController::FAQ.size
    assert_select ".cs-faq details[open]", 1
    assert_select "nav[aria-label=Topics] a[aria-current=page]", "All topics"
  end

  test "help filters by topic and by search, and highlights the match" do
    get help_path(topic: "gaps")
    assert_select ".cs-faq details", 2
    assert_select "nav[aria-label=Topics] a[aria-current=page]", "Gaps and hunting"

    get help_path(q: "export")
    assert_select ".cs-faq details", 2
    assert_select ".cs-faq details[open]", 2
    assert_select ".cs-faq mark", minimum: 1
  end

  test "help with no matches offers to show everything" do
    get help_path(q: "zzz")
    assert_select ".cs-empty", /No answers match that/
  end

  test "terms and privacy list their sections, and every link has a target" do
    [ terms_path, privacy_path ].each do |path|
      get path
      assert_response :success
      assert_select "nav[aria-labelledby=contents-title] li", 10
      css_select("nav[aria-labelledby=contents-title] a").each do |link|
        assert_select "section#{link["href"]}", 1
      end
    end
  end

  test "error pages show the right status and message" do
    { "/404" => [ 404, "This issue isn’t in the run" ],
      "/422" => [ 422, "We couldn’t save that" ],
      "/500" => [ 500, "We dropped the long box" ] }.each do |path, (status, headline)|
      get path
      assert_response status
      assert_select "h1", headline
      assert_select "header.cs-public-header"
    end
  end

    test "the 500 page gives a reference to quote" do
    get "/500"
    assert_select ".cs-error-text", /include this reference/
  end
end
