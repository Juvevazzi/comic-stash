require "test_helper"

# The Content Security Policy tells the browser to run only scripts and
# styles that come from Comic Stash itself, or that carry the session's
# nonce. Injected <script> tags (cross-site scripting) don't run.
class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "every page sends a Content Security Policy" do
    get login_path
    policy = response.headers["Content-Security-Policy"]
    assert policy, "no Content-Security-Policy header"
    assert_includes policy, "default-src 'self'"
    assert_includes policy, "object-src 'none'"
    assert_includes policy, "frame-ancestors 'none'"
    assert_match(/script-src 'self' 'nonce-[^']+'/, policy)
  end

  test "the page's own scripts carry the nonce" do
    get login_path
    nonce = response.headers["Content-Security-Policy"].to_s[/'nonce-([^']+)'/, 1]
    assert nonce, "no nonce in the policy"
    assert_select "script[nonce=?]", nonce, minimum: 2 # the theme script and the import map
  end
end
