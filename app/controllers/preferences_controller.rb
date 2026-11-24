# Preferences and notifications on your profile. Each switch saves as soon
# as it changes (auto-submit), then comes back to its section.
class PreferencesController < ApplicationController
  def update
    if Current.user.update(preferences_params)
      redirect_to profile_path(anchor: section), notice: "Saved. Your preferences are up to date."
    else
      redirect_to profile_path(anchor: section), alert: "That setting couldn't be saved. Try again."
    end
  end

  private

  def preferences_params
    params.expect(preferences: [ :appearance, :currency, :show_prices, :count_variants,
                                 :new_issues, :hunt_reminder, :monthly_report ])
  end

  def section
    params[:section] == "notifications" ? "notifications" : "preferences"
  end
end
