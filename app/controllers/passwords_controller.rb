# A user's forgot password page. Index = Forgot password.
# TODO: front-end only first then add back-end functionality. Actions only render views for now.

class PasswordsController < ApplicationController
  layout "public"

  # GET /forgot-password
  def new
  end

  # POST /forgot-password
  def create
    @email = params[:email].to_s.strip.downcase
    render :sent
  end
end
