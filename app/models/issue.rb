# One issue of a series, like Paper Moons #7. Shared by every user.
class Issue < ApplicationRecord
  belongs_to :series
  has_many :collection_items, dependent: :destroy

  # "#7 " is saved as "7".
  normalizes :number, with: ->(number) { number.strip.delete_prefix("#") }

  before_validation :set_sort_number

  validates :number, presence: true, length: { maximum: 20 },
                     uniqueness: { scope: :series_id, message: "is already in this series" }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :metron_id, uniqueness: true, allow_nil: true

  # 1, 2, 10 (not 1, 10, 2). Numbers with no digits, like "½", have no
  # sort_number, and PostgreSQL puts those last.
  scope :in_order, -> { order(:sort_number, :number) }

  # Out by the given day: the store date if Metron has one, else the cover
  # date. Upcoming issues are never counted as missing.
  scope :released, ->(on = Date.current) { where("COALESCE(issues.store_date, issues.cover_date) <= ?", on) }

  def label = "##{number}"

  def released?(on = Date.current)
    date = store_date || cover_date
    date.present? && date <= on
  end

  def to_s = "#{series.display_name} #{label}"

  private

  # The number at the start of the issue number: "12" -> 12, "1.5" -> 1.5, "½" -> nil.
  def set_sort_number
    self.sort_number = number.to_s[/\A\d+(?:\.\d+)?/]&.to_d
  end
end
