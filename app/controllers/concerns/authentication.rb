# The login wall, from the Rails 8 authentication generator. Included in
# ApplicationController, so every page needs a logged-in user unless its
# controller says allow_unauthenticated_access.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    # Not logged in: remember where they were going, then ask them to log in.
    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to login_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || dashboard_url
    end

    # remember: true is "Keep me logged in": a cookie that lasts 20 years.
    # Otherwise the cookie ends when the browser closes.
    def start_new_session_for(user, remember: false)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookie = { value: session.id, httponly: true, same_site: :lax }
        if remember
          cookies.signed.permanent[:session_id] = cookie
        else
          cookies.signed[:session_id] = cookie
        end
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
