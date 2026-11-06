require "test_helper"

# The User model's rules, tested directly (no web requests).
class UserTest < ActiveSupport::TestCase
  def new_user(**changes)
    User.new({ name: "Juno Vale", email_address: "juno@example.com", password: "comics123",
               terms_accepted: "1" }.merge(changes))
  end

  test "a complete sign-up is valid" do
    assert new_user.valid?
  end

  test "email is saved in lower case without spaces" do
    assert_equal "juno@example.com", new_user(email_address: "  JUNO@Example.COM ").email_address
  end

  test "email must look like an email and not be taken, whatever the case" do
    assert_not new_user(email_address: "not-an-email").valid?
    assert_not new_user(email_address: "RG@example.com").valid?
  end

  test "password needs at least 8 characters and a number" do
    assert_not new_user(password: "short1").valid?
    assert_not new_user(password: "noNumbersHere").valid?
  end

  test "terms must be accepted to sign up" do
    assert_not new_user(terms_accepted: "0").valid?
    assert_not new_user(terms_accepted: nil).valid?
  end

  test "currency must be one we support" do
    assert_not new_user(currency: "XYZ").valid?
  end

  test "initials come from the first two names" do
    assert_equal "RG", users(:ricardo).initials
  end

  test "changing the password records when" do
    user = users(:ricardo)
    user.update!(password: "another99")
    assert_in_delta Time.current, user.password_changed_at, 5.seconds
  end

  test "the current password must match to set a new one" do
    user = users(:ricardo)
    assert_not user.update(password: "another99", password_challenge: "wrong")
    assert user.errors.key?(:password_challenge)
  end

  test "deleting a user deletes their sessions" do
    user = users(:ricardo)
    user.sessions.create!
    assert_difference("Session.count", -1) { user.destroy }
  end

    test "your run of a series counts only released issues" do
    run = users(:ricardo).run_for(series(:paper_moons))
    assert_equal 4, run.total
    assert_equal 3, run.owned_count
    assert_equal [ "#3" ], run.gaps
  end

  test "owned and hunted issues are kept apart" do
    ricardo = users(:ricardo)
    assert_equal %w[1 2 4], ricardo.owned_issues.in_order.pluck(:number)
    assert_equal %w[3], ricardo.hunted_issues.pluck(:number)
  end

  test "collected series are the ones with something in your stash" do
    assert_equal [ series(:paper_moons) ], users(:ricardo).collected_series.to_a
  end

  test "each user has their own stash" do
    assert_equal %w[1], users(:ada).owned_issues.pluck(:number)
  end

  test "deleting a user deletes their stash but not the catalogue" do
    assert_difference -> { CollectionItem.count } => -4, -> { Issue.count } => 0 do
      users(:ricardo).destroy
    end
  end
end
