# Your profile (wireframe: User profile). show = the page, update = the
# Profile form, destroy = Delete account. Front-end stage: the sample
# account stands in for current_user, and nothing is saved yet.
class ProfilesController < ApplicationController
  CONFIRM_PHRASE = "delete my stash".freeze

  before_action :load_profile

  def show
  end

  # PATCH /profile: name, email and (optionally) a new password.
  def update
    details = params.expect(user: [ :name, :email_address, :password_challenge, :password ])
    @errors = profile_errors(details)

    if @errors.any?
      # Show the form again with what was typed and the messages. 422 tells
      # Turbo to replace the page with this response.
      @account = @account.with(name: details[:name], email_address: details[:email_address])
      render :show, status: :unprocessable_content
    else
      redirect_to profile_path, notice: "Saved. Your profile is up to date."
    end
  end

  # DELETE /profile: only when the confirmation phrase was typed exactly.
  def destroy
    if params[:confirm].to_s.strip.downcase == CONFIRM_PHRASE
      redirect_to login_path, notice: "Your account and your stash have been deleted."
    else
      redirect_to profile_path(anchor: "account"), alert: "Type “#{CONFIRM_PHRASE}” to delete your account."
    end
  end

  private

  def load_profile
    @account = SampleStash.account
    @preferences = SampleStash.preferences
    @stats = SampleStash.stats
    @errors = {}
  end

  # Field => message for everything wrong with the submitted details.
  def profile_errors(details)
    errors = {}
    errors[:name] = "Enter the name to show on your profile." if details[:name].blank?
    unless details[:email_address].to_s.match?(URI::MailTo::EMAIL_REGEXP)
      errors[:email_address] = "Enter an email like name@example.com."
    end
    if details[:password].present?
      errors[:password_challenge] = "Enter your current password to change it." if details[:password_challenge].blank?
      errors[:password] = "Use at least 8 characters, including a number." unless details[:password].match?(/\A(?=.*\d).{8,}\z/)
    end
    errors
  end
end
