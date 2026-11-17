# Imports one series from Metron in the background, so no page ever waits
# on Metron, and a busy minute just means trying again a little later.
class ImportSeriesJob < ApplicationJob
  queue_as :default

  # Metron allows 20 requests a minute: wait, then try again (5 tries in all).
  retry_on Longbox::Metron::RateLimited, wait: 1.minute, attempts: 5
  # Metron having a bad moment: wait a little longer after each try.
  retry_on Longbox::Metron::ServerError, wait: :polynomially_longer, attempts: 5
  # A series Metron doesn't have will never work, so don't keep trying.
  discard_on Longbox::Metron::NotFound

  def perform(metron_id)
    MetronImport.new.import_series(metron_id)
  end
end
