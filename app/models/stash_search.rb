# Searches for one term in three places: your series, your issues, and the
# catalogue series you don't collect yet. All three are database queries
# using ILIKE, so capitals don't matter.
class StashSearch
  attr_reader :term

  def initialize(stash, query)
    @stash = stash
    @term = query.to_s.strip
  end

  def blank? = term.empty?

  def series
    @series ||= blank? ? [] : @stash.series.where("series.name ILIKE ?", like).order(:sort_name).to_a
  end

  # Your issues whose series, title or creators contain the term, whose
  # number is the term ("12" or "#12"), or that match "series #number"
  # ("paper moons #3"). statuses narrows them to owned, missing or hunting.
  def issues(statuses = [])
    return [] if blank?

    rows = @stash.issues.includes(:series).where(<<~SQL, like: like, number: term.delete_prefix("#"))
      series_name ILIKE :like OR title ILIKE :like OR number = :number
        OR (series_name || ' #' || number) ILIKE :like
        OR EXISTS (SELECT 1 FROM jsonb_array_elements(credits) credit WHERE credit->>'name' ILIKE :like)
    SQL
    rows = rows.where("stash_status IN (?)", statuses) if statuses.any?
    rows.order(:series_sort_name, :sort_number, :number).to_a
  end

  # Catalogue series (imported from Metron) that aren't in your stash yet.
  def catalogue
    @catalogue ||= blank? ? [] : Series.with_cover.where.not(id: @stash.series.select(:id)).where("name ILIKE ?", like)
                                       .includes(:publisher).order(:sort_name).to_a
  end

  private

  # "%night%", with any % or _ the user typed escaped.
  def like = "%#{ActiveRecord::Base.sanitize_sql_like(term)}%"
end
