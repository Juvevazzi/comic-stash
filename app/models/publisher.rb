# A comic publisher. Shared by every user; most come from Metron.
class Publisher < ApplicationRecord
  # A publisher can't be deleted while any series still points at it.
  has_many :series, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 120 }
  validates :metron_id, uniqueness: true, allow_nil: true
end
