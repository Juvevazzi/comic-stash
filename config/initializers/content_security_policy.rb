# Content Security Policy: the browser only runs scripts, styles, fonts and
# images from Comic Stash itself, plus the few inline ones Rails marks with
# a nonce (a random value that changes per session). A <script> someone
# manages to inject into a page has no nonce, so it doesn't run.
# See https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.style_src :self
    policy.style_src_attr :unsafe_inline # style="width: 75%" on the progress bars
    policy.font_src :self, :data
    policy.img_src :self, :data, :https # data: for Bootstrap's icons, https: for Metron covers
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :none # no other site can show Comic Stash in a frame (clickjacking)
  end

  # The nonce for the import map, the theme script and Turbo's progress bar.
  # It's made once and kept in the session, so it stays the same while Turbo
  # swaps pages. (Rails' default uses the session id, which is still empty on
  # a first visit, so the log-in page got the useless 'nonce-'.)
  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
  # javascript_tag, javascript_include_tag and stylesheet_link_tag add the nonce themselves.
  config.content_security_policy_nonce_auto = true
end
