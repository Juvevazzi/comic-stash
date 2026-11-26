# One issue of a series, like Paper Moons #7. Shared by every user.
class Issue < ApplicationRecord
  belongs_to :series
  has_many :collection_items, dependent: :destroy

  # "#7 " is saved as "7".
  normalizes :number, with: ->(number) { number.strip.delete_prefix("#") }

  before_validation :set_sort_number

  belongs_to :added_by, class_name: "User", optional: true

  validates :number, presence: true, length: { maximum: 20 },
                    uniqueness: { scope: [ :series_id, :added_by_id ], message: "is already in this series" }

  # The catalogue plus this user's own hand-added issues.
  scope :visible_to, ->(user) { where(added_by_id: [ nil, user.id ]) }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :metron_id, uniqueness: true, allow_nil: true

  # 1, 2, 10 (not 1, 10, 2). Numbers with no digits, like "½", have no
  # sort_number, and PostgreSQL puts those last.
  scope :in_order, -> { order(:sort_number, :number) }

  # Out by the given day: the store date if Metron has one, else the cover
  # date. Upcoming issues are never counted as missing.
  scope :released, ->(on = Date.current) { where("COALESCE(issues.store_date, issues.cover_date) <= ?", on) }

  # Issues with a creator whose name contains text. role: "Cover" narrows it
  # to cover artists. credits is jsonb, so PostgreSQL looks inside the list.
  scope :by_creator, ->(text, role: nil) {
    where(<<~SQL, like: "%#{sanitize_sql_like(text.strip)}%", role: role && [ role ].to_json)
      EXISTS (SELECT 1 FROM jsonb_array_elements(issues.credits) credit
              WHERE credit->>'name' ILIKE :like
                AND (CAST(:role AS jsonb) IS NULL OR credit->'roles' @> CAST(:role AS jsonb)))
    SQL
  }

  def label = "##{number}"

  def released?(on = Date.current)
    date = store_date || cover_date
    date.present? && date <= on
  end

  def to_s = "#{series.display_name} #{label}"

  # A colour for the placeholder cover, shared by every issue of a series.
  def tone = Series.tone_for(series_id)

  # The day it came out, or comes out: the store date, else the cover date.
  def released_on = store_date || cover_date

  # "Paper Moons 3", or "Issue #3" until Metron sends a title.
  def display_title = title.presence || "Issue #{label}"

  # Your status for this issue. Only set on issues loaded through Stash,
  # which adds stash_status to each row; anywhere else these are false.
  def owned? = self[:stash_status] == "owned"
  def hunting? = self[:stash_status] == "hunting"
  def missing? = !owned?

  # Metron's credits as [role, name] pairs, split the way View issue shows them.
  def credit_pairs = credits.flat_map { |credit| Array(credit["roles"]).map { |role| [ role, credit["name"] ] } }
  def cover_artists = credit_pairs.filter_map { |role, name| name if role == "Cover" }.uniq
  def editors = credit_pairs.select { |role, _name| role.match?(/editor/i) }
  def story_credits = credit_pairs.reject { |role, _name| role == "Cover" || role.match?(/editor/i) }

  # From Metron, but its credits and description haven't been fetched yet.
  def needs_details? = metron_id.present? && credits.empty? && description.blank?

  DETAILS_RETRY_AFTER = 1.hour

  # Queues one details fetch, at most once an hour per issue, however many
  # people open it. The UPDATE only succeeds for the first request.
  def request_details!
    return unless needs_details?

    claimed = Issue.where(id: id)
                  .where("details_requested_at IS NULL OR details_requested_at < ?", DETAILS_RETRY_AFTER.ago)
                  .update_all(details_requested_at: Time.current)
    ImportIssueDetailsJob.perform_later(self) if claimed == 1
  end

  # The issues either side of this one in its series: [previous, next],
  # with nil at either end.
  def neighbours(user)
    ids = series.issues.visible_to(user).in_order.ids
    place = ids.index(id)
    [ (Issue.find(ids[place - 1]) if place.positive?), Issue.find_by(id: ids[place + 1]) ]
  end

  private

  # The number at the start of the issue number: "12" -> 12, "1.5" -> 1.5, "½" -> nil.
  def set_sort_number
    self.sort_number = number.to_s[/\A\d+(?:\.\d+)?/]&.to_d
  end
end
