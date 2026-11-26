# Copies a series and its issues from Metron into the catalogue, using the
# Longbox client from step 19. Safe to run again: rows are matched on
# metron_id, so a second import updates them instead of making copies.
class MetronImport
  class << self
    attr_writer :client

    # The real client, built from the API token in credentials (step 19).
    # Tests set MetronImport.client to a fake instead.
    def client
      @client ||= Longbox::Metron::Client.new(token: Rails.application.credentials.dig(:metron, :api_token))
    end

    # For page views: give up after a few seconds rather than hold the page.
    def interactive_client
      @interactive_client ||= Longbox::Metron::Client.new(
        token: Rails.application.credentials.dig(:metron, :api_token),
        transport: Longbox::Metron::HttpTransport.new(open_timeout: 2, read_timeout: 4)
      )
    end
  end

  def initialize(client: self.class.client)
    @client = client
  end

  # One series and every issue in it: two requests, or a few more for a
  # long series (100 issues a page). Both requests happen before anything is
  # saved, so a Metron error leaves the catalogue as it was.
  def import_series(metron_id)
    data = @client.series(metron_id)
    rows = @client.series_issues(metron_id)

    Series.transaction do
      series = Series.find_or_initialize_by(metron_id: data.fetch("id"))
      series.update!(series_attributes(data))
      rows.each { |row| import_issue_row(series, row) }
      series
    end
  end

  # What only the single-issue endpoint has: credits, characters, the
  # description and price. One request per issue, so it's fetched when an
  # issue is first looked at rather than for a whole series at once.
  def import_issue_details(issue)
    data = @client.issue(issue.metron_id)
    issue.update!(
      title: data["title"].presence || Array(data["name"]).first,
      description: data["desc"].presence,
      price: data["price"].presence,
      page_count: data["page"],
      upc: data["upc"].presence,
      isbn: data["isbn"].presence,
      image_url: data["image"].presence || issue.image_url,
      credits: Array(data["credits"]).map { |credit| { "name" => credit["creator"], "roles" => Array(credit["role"]).pluck("name") } },
      characters: Array(data["characters"]).pluck("name"),
      metron_modified_at: data["modified"]
    )
    issue
  end

  private

  def series_attributes(data)
    {
      publisher: publisher_for(data["publisher"]),
      name: data.fetch("name"),
      volume: data["volume"],
      year_began: data["year_began"],
      year_end: data["year_end"],
      series_type: data.dig("series_type", "name"),
      status: data["status"],
      issue_count: data["issue_count"],
      description: data["desc"].presence,
      metron_modified_at: data["modified"]
    }
  end

  def publisher_for(data)
    return if data.blank?

    Publisher.find_or_initialize_by(metron_id: data.fetch("id")).tap do |publisher|
      publisher.update!(name: data.fetch("name"))
    end
  end

  def import_issue_row(series, row)
    issue = Issue.find_by(metron_id: row.fetch("id")) ||
            series.issues.find_or_initialize_by(number: row.fetch("number"), added_by_id: nil)
    issue.update!(series: series, number: row.fetch("number"), metron_id: row.fetch("id"),
                  cover_date: row["cover_date"], store_date: row["store_date"],
                  image_url: row["image"].presence || issue.image_url,
                  metron_modified_at: row["modified"])
    adopt_private_copies(issue)
  end

  # Move everyone's hand-added copy of this issue onto the real one, then delete the copies.
  def adopt_private_copies(issue)
    copies = issue.series.issues.where(number: issue.number).where.not(added_by_id: nil)
    copies.find_each do |copy|
      CollectionItem.where(issue: copy).where.not(user_id: issue.collection_items.select(:user_id))
                    .update_all(issue_id: issue.id)
      copy.destroy # removes any duplicate collection item left on it
    end
  end
end
