class PreferencesController < ApplicationController
  def update
    params.expect(preferences: [ :appearance, :currency, :show_prices, :count_variants,
                                 :new_issues, :hunt_reminder, :monthly_report ])
    redirect_to profile_path(anchor: params[:section] == "notifications" ? "notifications" : "preferences"),
                notice: "Saved. Your preferences are up to date."
  end
end
