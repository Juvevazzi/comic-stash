# One issue in one user's stash: owned, or on their hunt list.
# "Got it" turns hunting into owned.
class CollectionItem < ApplicationRecord
  belongs_to :user
  belongs_to :issue

  # validate: true makes an unknown status a validation error rather than a crash.
  enum :status, { owned: 0, hunting: 1 }, default: :owned, validate: true

  validates :issue_id, uniqueness: { scope: :user_id, message: "is already in your stash" }
  validates :notes, length: { maximum: 2000 }
end
