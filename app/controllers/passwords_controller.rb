# Forgotten passwords (wireframes: Forgot password, Check your email) and the
# page the emailed link opens. From the Rails 8 generator: the link carries a
# signed token that expires after 15 minutes and stops working as soon as
# the password changes, so it can only be used once.
class PasswordsController < ApplicationController
  layout "public"

  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to forgot_password_path, alert: "Too many requests. Wait a few minutes and try again." }

  # GET /forgot-password
  def new
  end

  # POST /forgot-password. Always goes on to "Check your email", whether or
  # not there's an account, so this page can't be used to find out who has
  # one. It redirects rather than renders, because Turbo only follows a form
  # to a new page when the response is a redirect.
  def create
    email = params[:email].to_s.strip.downcase
    if (user = User.find_by(email_address: email))
      PasswordsMailer.reset(user).deliver_later
    end
    redirect_to password_reset_sent_path, flash: { reset_email: email }
  end

  # GET /forgot-password/sent. The flash carries the address for one page view.
  def sent
    @email = flash[:reset_email]
  end

  # GET /passwords/:token/edit
  def edit
    @errors = {}
  end

  # PUT /passwords/:token
  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all # log out everywhere, in case someone else got in
      redirect_to login_path, notice: "Your password has been changed. Log in with the new one."
    else
      @errors = @user.errors.messages.transform_values(&:first)
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to forgot_password_path, alert: "That reset link has expired or was already used. Ask for a new one."
  end
end
