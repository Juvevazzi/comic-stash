class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Comic Stash <no-reply@example.com>")
  layout "mailer"
end
