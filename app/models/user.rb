# Someone with a Comic Stash account. has_secure_password (bcrypt) stores
# only a one-way hash of the password, and adds User.authenticate_by, the
# password_challenge check and password reset tokens.
class User < ApplicationRecord
  CURRENCIES = %w[EUR GBP USD CAD].freeze
  APPEARANCES = %w[light dark system].freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collection_items, dependent: :destroy
  has_many :issues, through: :collection_items

  # " RG@Example.com " is saved, and looked up, as "rg@example.com".
  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: { message: "Enter the name to show on your profile." }, length: { maximum: 80 }
  validates :email_address,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Enter an email like name@example.com." },
            uniqueness: { message: "There's already an account with this email. Try logging in." }
  # allow_nil: the rule only applies when a new password is being set.
  validates :password, allow_nil: true,
                       format: { with: /\A(?=.*\d).{8,72}\z/, message: "Use at least 8 characters, including a number." }
  # A box on the sign-up form, not a column: checked once, when the account is made.
  validates :terms_accepted, acceptance: { allow_nil: false, message: "Agree to the Terms and Privacy policy to continue." },
                             on: :create
  validates :currency, inclusion: { in: CURRENCIES }
  validates :appearance, inclusion: { in: APPEARANCES }

  before_save :stamp_password_change, if: :will_save_change_to_password_digest?

  # "Ricardo Giacovazzi" -> "RG", for the avatar in the navbar.
  def initials
    name.split.first(2).map { |word| word[0] }.join.upcase
  end

  def first_name = name.split.first

  def member_since = created_at.to_date

  def owned_issues = issues.merge(CollectionItem.owned)

  def hunted_issues = issues.merge(CollectionItem.hunting)

  # The series you collect: every series with at least one issue in your stash.
  def collected_series = Series.where(id: issues.select(:series_id))

  # Your run of one series, worked out by the Longbox gem from two lists of
  # issue numbers: what's been released, and what you own.
  def run_for(series)
    Longbox::Run.new(released: series.issues.released.pluck(:number),
                     owned: owned_issues.where(series: series).pluck(:number))
  end

  private

  def stamp_password_change
    self.password_changed_at = Time.current
  end
end
