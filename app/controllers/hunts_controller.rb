# The hunt list: POST /comics/:comic_id/hunt puts an issue on it, DELETE
# takes it off. Both change only your own stash, and come back to the page
# you were on.
class HuntsController < ApplicationController
  before_action :set_issue

  def create
    Current.user.hunt!(@issue)
    redirect_back_or_to comic_path(@issue), notice: "#{@issue} is on your hunt list."
  end

  def destroy
    Current.user.unhunt!(@issue)
    redirect_back_or_to comic_path(@issue), notice: "#{@issue} is off your hunt list."
  end

  private

  def set_issue
    @issue = Issue.find(params[:comic_id])
  end
end
