# A user's sign up page. New = Sign up and create a new account.
# TODO: front-end only first then add back-end functionality. Actions only render views for now.

class RegistrationsController < ApplicationController
  layout "auth"

  # GET /signup
  def new
  end

  # POST /signup
  def create
    redirect_to dashboard_path, notice: "Your stash is ready. Add your first comic to get going."
  end
end
