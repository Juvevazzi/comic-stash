# A series: one run of a title, like Paper Moons Vol. 2. Shared by every
# user; what each user owns lives in CollectionItem.
class Series < ApplicationRecord
  belongs_to :publisher, optional: true
  has_many :issues, dependent: :destroy

  normalizes :name, with: ->(name) { name.squish }

  before_validation :set_sort_name

  validates :name, presence: true, length: { maximum: 200 }
  validates :volume, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :year_began, :year_end, numericality: { only_integer: true, in: 1900..2100 }, allow_nil: true
  validates :metron_id, uniqueness: true, allow_nil: true
  validate :ends_after_it_began

  # A to Z the way a shop files them: "The Long Box Kids" under L.
  scope :alphabetical, -> { order(:sort_name, :year_began) }

  # "Paper Moons Vol. 2"; volume 1 (or unknown) is just the name.
  def display_name
    volume.to_i > 1 ? "#{name} Vol. #{volume}" : name
  end

  TONES = %i[cyan magenta yellow].freeze

  # A colour for the placeholder covers, picked from the id so it never changes.
  def self.tone_for(id) = TONES[id.to_i % TONES.size]

  def tone = self.class.tone_for(id)

  # The first issue's cover from Metron, as an extra column in a query.
  COVER_SELECT = <<~SQL.squish.freeze
    (SELECT i.image_url FROM issues i
      WHERE i.series_id = series.id AND i.image_url <> ''
      ORDER BY i.sort_number NULLS LAST, i.id LIMIT 1) AS cover_url
  SQL

  # Series with their cover_url, worked out in the same query.
  scope :with_cover, -> { select("series.*", COVER_SELECT) }

  # The cover to show for this series: its first issue's cover, or nil for
  # the placeholder. Free on series loaded with_cover or through Stash#series;
  # one small query otherwise.
  def cover_url
    return self[:cover_url] if has_attribute?(:cover_url)

    issues.where.not(image_url: [ nil, "" ]).order(:sort_number, :id).pick(:image_url)
  end

  # "2019–present", "2021–2023".
  def years = year_began ? "#{year_began}–#{year_end || "present"}" : "Year unknown"

  # Released issues you own. Only on series loaded through Stash#series,
  # which counts released_count and missing_count in the database.
  def owned_count = self[:released_count].to_i - self[:missing_count].to_i

  private

  def set_sort_name
    self.sort_name = name.sub(/\AThe\s+/i, "") if name.present?
  end

  def ends_after_it_began
    return if year_began.nil? || year_end.nil? || year_end >= year_began

    errors.add(:year_end, "can't be before the year the series began")
  end
end
