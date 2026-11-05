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

  private

  def set_sort_name
    self.sort_name = name.sub(/\AThe\s+/i, "") if name.present?
  end

  def ends_after_it_began
    return if year_began.nil? || year_end.nil? || year_end >= year_began

    errors.add(:year_end, "can't be before the year the series began")
  end
end
