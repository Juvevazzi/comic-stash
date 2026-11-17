# Fetches one issue's credits, characters, description and price from Metron
# in the background. View issue queues it the first time someone opens an
# issue that hasn't got them yet, so the page itself never waits on Metron.
class ImportIssueDetailsJob < ApplicationJob
  queue_as :default

  retry_on Longbox::Metron::RateLimited, wait: 1.minute, attempts: 5
  retry_on Longbox::Metron::ServerError, wait: :polynomially_longer, attempts: 5
  discard_on Longbox::Metron::NotFound
  # The issue was deleted before the job ran: nothing left to fill in.
  discard_on ActiveJob::DeserializationError

  def perform(issue)
    MetronImport.new.import_issue_details(issue)
  end
end
