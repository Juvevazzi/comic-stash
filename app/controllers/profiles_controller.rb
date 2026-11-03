# Your profile (wireframe: User profile). show = the page, update = the
# Profile form, destroy = Delete account. Everything here is about the
# logged-in user, Current.user, so there's no :id in the URL.
class ProfilesController < ApplicationController
  CONFIRM_PHRASE = "delete my stash".freeze

  before_action :load_profile

  def show
  end

  # PATCH /profile: name, email and (optionally) a new password.
  def update
    if @account.update(profile_params)
      redirect_to profile_path, notice: "Saved. Your profile is up to date."
    else
      # Show the form again with what was typed and the model's messages.
      @errors = @account.errors.messages.transform_values(&:first)
      render :show, status: :unprocessable_content
    end
  end

  # DELETE /profile: only when the confirmation phrase was typed exactly.
  def destroy
    if params[:confirm].to_s.strip.downcase == CONFIRM_PHRASE
      terminate_session
      @account.destroy # and, through dependent: :destroy, everything that belongs to it
      redirect_to login_path, notice: "Your account and your stash have been deleted.", status: :see_other
    else
      redirect_to profile_path(anchor: "account"), alert: "Type “#{CONFIRM_PHRASE}” to delete your account."
    end
  end

  private

  def load_profile
    @account = Current.user
    @preferences = Current.user
    @stats = SampleStash.stats # real numbers in step 22
    @errors = {}
  end

  # Leaving the new password empty means "don't change it". When there is a
  # new password, the current one is always checked: has_secure_password
  # compares password_challenge with the saved password, and "" never matches.
  def profile_params
    details = params.expect(user: [ :name, :email_address, :password_challenge, :password ])
    if details[:password].blank?
      details.except(:password, :password_challenge)
    else
      details.merge(password_challenge: details[:password_challenge].to_s)
    end
  end
end
