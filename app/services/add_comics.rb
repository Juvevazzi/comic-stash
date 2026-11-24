require "csv"

# Adds comics to one user's stash from what they type on Add comics: a
# series name, an issue number and, if they have it, a barcode. A series or
# issue the catalogue doesn't have yet is made on the spot, so you can add
# any comic, imported from Metron or not.
#
#   AddComics.new(Current.user).add(series_name: "Paper Moons Vol. 2", number: "7")
#   AddComics.new(Current.user).add_all(AddComics.range("Iron Tide", "1", "12"))
class AddComics
  Row = Data.define(:series_name, :number, :barcode)
  Result = Data.define(:added, :problems)

  MAX_ROWS = 500

  # The three bulk forms, turned into rows.
  def self.range(series_name, from, to)
    (from.to_i..to.to_i).first(MAX_ROWS + 1).map { |number| Row.new(series_name, number.to_s, nil) }
  end

  # "Iron Tide, 11, 76194134182501111" per line; blank lines are skipped.
  def self.parse_lines(text)
    text.to_s.lines.map(&:strip).reject(&:empty?).map do |line|
      series_name, number, barcode = CSV.parse_line(line).map { |cell| cell.to_s.strip }
      Row.new(series_name, number, barcode)
    end
  rescue CSV::MalformedCSVError
    [ Row.new(nil, nil, nil) ]
  end

  # A CSV file with a header row: series,issue,barcode.
  def self.parse_csv(text)
    CSV.parse(text.to_s, headers: true).map { |row| Row.new(row["series"]&.strip, row["issue"]&.strip, row["barcode"]&.strip) }
  rescue CSV::MalformedCSVError
    [ Row.new(nil, nil, nil) ]
  end

  def initialize(user)
    @user = user
    @series = {}
  end

  # One comic. Raises ActiveRecord::RecordInvalid if it can't be saved.
  def add(series_name:, number:, barcode: nil)
    issue = issue_for(series_for(series_name.to_s), number, barcode)
    @user.collect!(issue)
  end

  # Many comics, all or nothing: one bad line and nothing is added, so a
  # half-added CSV never needs tidying up.
  def add_all(rows)
    problems = check(rows)
    return Result.new(added: [], problems: problems) if problems.any?

    added = []
    CollectionItem.transaction do
      rows.each_with_index do |row, index|
        added << add(series_name: row.series_name, number: row.number, barcode: row.barcode)
      rescue ActiveRecord::RecordInvalid => error
        problems << "Line #{index + 1}: #{error.record.errors.full_messages.to_sentence}."
        raise ActiveRecord::Rollback
      end
    end
    Result.new(added: problems.any? ? [] : added, problems: problems)
  end

  private

  def check(rows)
    return [ "Nothing to add." ] if rows.empty?
    return [ "That's more than #{MAX_ROWS} comics. Split it into smaller batches." ] if rows.size > MAX_ROWS

    rows.each_with_index.filter_map do |row, index|
      "Line #{index + 1}: needs a series name and an issue number." if row.series_name.blank? || row.number.blank?
    end
  end

  # "Paper Moons Vol. 2" is the series called Paper Moons, volume 2. The
  # name matches whatever the capitals; volume 1 matches a series with no
  # volume too. Not in the catalogue: a new series is made.
  def series_for(text)
    @series[text.squish.downcase] ||= begin
      name, volume = text.squish.match(/\A(.*?)(?:\s+vol\.?\s*(\d+))?\z/i).captures
      volume = volume&.to_i
      Series.where("LOWER(name) = LOWER(?)", name).where(volume: volume.to_i > 1 ? volume : [ nil, 1 ]).order(:id).first ||
        Series.create!(name: name, volume: volume)
    end
  end

  # An issue you're holding is out, so a new one gets today's date until a
  # Metron import fills in the real one. The barcode is kept if the issue
  # hasn't got one.
  def issue_for(series, number, barcode)
    issue = series.issues.find_or_create_by!(number: number.to_s) { |new_issue| new_issue.store_date = Date.current }
    issue.update!(upc: barcode) if barcode.present? && issue.upc.blank?
    issue
  end
end
