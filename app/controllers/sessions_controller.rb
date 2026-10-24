# A user's login session page. New = Login and display login form.
# TODO: front-end only first then add back-end functionality. Actions only render views for now.

class SessionsController < ApplicationController
  layout "auth"

  # GET /login
  def new
  end

  # POST /login
  def create
    redirect_to dashboard_path, notice: "Welcome back."
  end
end
