# Searches your stash and the catalogue for one search term, for the
# front-end stage. It answers three questions: which of your series, which
# issues and which catalogue series match. With the models these become
# database queries (or a search gem); the controller and views stay the same.
class SampleSearch
  STATUSES = %w[owned missing hunting].freeze

  attr_reader :term

  def initialize(query)
    @term = query.to_s.strip
  end

  def blank?
    term.empty?
  end

  def series
    @series ||= blank? ? [] : SampleStash.series_list.select { |series| match?(series.name) }
  end

  def issues
    @issues ||= blank? ? [] : matching_issues
  end

  def catalogue
    @catalogue ||= blank? ? [] : SampleStash.catalogue.select { |entry| match?(entry.name) }
  end

  # Every issue is owned, hunting (missing and on your hunt list) or missing.
  def self.status(comic)
    if !comic.missing
      "owned"
    elsif SampleStash::HUNTING.include?(comic.id)
      "hunting"
    else
      "missing"
    end
  end

  private

  def matching_issues
    SampleStash.all_comics.select { |comic| issue_match?(comic) }.sort_by { |comic| [ comic.series, comic.issue ] }
  end

  def match?(text)
    text.downcase.include?(term.downcase)
  end

  # Series, title or cover artist contain the term, or it's the issue
  # number ("12" or "#12"), or "series #number" ("night signal #52").
  def issue_match?(comic)
    match?(comic.series) || match?(comic.title) || match?(comic.artists) ||
      comic.issue.to_s == term.delete_prefix("#") || match?("#{comic.series} ##{comic.issue}")
  end
end
