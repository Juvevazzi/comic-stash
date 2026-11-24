# Logging in and out (wireframe: Log in). The Authentication concern
# (app/controllers/concerns/authentication.rb, from the Rails 8 generator)
# keeps track of who's logged in; this controller starts and ends sessions.
class SessionsController < ApplicationController
  layout "auth"

  allow_unauthenticated_access only: %i[new create]
  # At most 10 tries every 3 minutes from one IP address, to slow down
  # anyone guessing passwords.
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, alert: "Too many tries. Wait a few minutes and try again." }

  # GET /login
  def new
    redirect_to dashboard_path if authenticated?
  end

  # POST /login
  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for user, remember: params[:remember_me] == "1"
      redirect_to after_authentication_url, notice: "Welcome back, #{user.first_name}."
    else
      # Same message whether the email or the password was wrong, so the
      # form can't be used to find out who has an account.
      flash.now[:alert] = "That email and password don't match. Try again, or reset your password."
      render :new, status: :unprocessable_content
    end
  end

  # DELETE /logout
  def destroy
    terminate_session
    redirect_to login_path, notice: "You're logged out. Your collection is safe until you're back.", status: :see_other
  end
end
