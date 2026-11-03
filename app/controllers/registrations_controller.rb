# Sign up (wireframe: Sign up). Creates the account, then logs straight in.
class RegistrationsController < ApplicationController
  layout "auth"

  allow_unauthenticated_access
  rate_limit to: 5, within: 1.hour, only: :create,
             with: -> { redirect_to signup_path, alert: "Too many new accounts from here. Try again later." }

  # GET /signup
  def new
    return redirect_to(dashboard_path) if authenticated?

    @user = User.new
    @errors = {}
  end

  # POST /signup
  def create
    @user = User.new(params.expect(user: %i[name email_address password terms_accepted]))

    if @user.save
      start_new_session_for @user, remember: true
      redirect_to dashboard_path, notice: "Your stash is ready. Add your first comic to get going."
    else
      # field => first message, for the field helpers in the form.
      @errors = @user.errors.messages.transform_values(&:first)
      render :new, status: :unprocessable_content
    end
  end
end
