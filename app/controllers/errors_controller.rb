# Branded error pages. config.exceptions_app sends errors here in production
# instead of serving public/404.html and friends. Keep this controller
# simple: if it failed too, Rails could only show a plain-text error.
class ErrorsController < ApplicationController
  layout "public"

  allow_unauthenticated_access only: :show

  # A failed form (e.g. an expired one) arrives here as a POST, and checking
  # its CSRF token again would just raise the same error.
  skip_forgery_protection

  # Status => [name, headline, what happened]
  MESSAGES = {
    404 => [ "Page not found", "This issue isn’t in the run",
             "We couldn’t find that page. It may have moved, or there’s a typo in the link." ],
    422 => [ "Couldn’t process", "We couldn’t save that",
             "Something you entered didn’t pass our checks, or the page was open for a long time. Go back, check the form and try again." ],
    500 => [ "Server error", "We dropped the long box",
             "Something went wrong on our side. Your collection is safe. Try again in a moment." ]
  }.freeze

  def show
    @code = MESSAGES.key?(params[:code].to_i) ? params[:code].to_i : 500
    @name, @headline, @body = MESSAGES.fetch(@code)
    # Always HTML, even when the failed request asked for something else (like .csv).
    render :show, status: @code, formats: :html, content_type: "text/html"
  end
end
