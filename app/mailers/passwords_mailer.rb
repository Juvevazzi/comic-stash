class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset your Comic Stash password", to: user.email_address
  end
end
