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
      if @account.saved_change_to_password_digest? || @account.saved_change_to_email_address?
        @account.sessions.where.not(id: Current.session.id).destroy_all
      end
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
    @stats = Stash.new(Current.user).stats
    @errors = {}
  end

  def profile_params
    details = params.expect(user: [ :name, :email_address, :password_challenge, :password ])
    details.delete(:password) if details[:password].blank?

    if details.key?(:password) || email_changing?(details)
      details[:password_challenge] = details[:password_challenge].to_s # "" never matches
    else
      details.delete(:password_challenge)
    end
    details
  end

  def email_changing?(details)
    details[:email_address].present? &&
      details[:email_address].strip.downcase != @account.email_address
  end
end
