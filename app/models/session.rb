class Session < ApplicationRecord
  IDLE_TIMEOUT = 30.days # unused this long: logged out
  MAX_AGE = 1.year       # however active, log in again after this

  belongs_to :user

  scope :expired, -> { where(last_active_at: ...IDLE_TIMEOUT.ago).or(where(created_at: ...MAX_AGE.ago)) }

  def expired? = last_active_at < IDLE_TIMEOUT.ago || created_at < MAX_AGE.ago

  # At most one write an hour per session, not one per page view.
  def record_activity!
    update_column(:last_active_at, Time.current) if last_active_at < 1.hour.ago
  end
end
