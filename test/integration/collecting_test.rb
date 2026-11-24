require "test_helper"

# Got it, Remove and the hunt list, from the fixtures: Ricardo owns Paper
# Moons #1, #2 and #4 and is hunting #3; Ada owns #1. Every change lands in
# the logged-in user's stash and nobody else's.
class CollectingTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper # View issue queues a Metron job; this keeps it in the test queue

  setup { sign_in_as users(:ricardo) }

  test "got it moves an issue from the hunt list into your stash, with an Undo" do
    issue = issues(:paper_moons_3)
    patch comic_path(issue), params: { comic: { owned: "true" } }
    assert collection_items(:ricardo_paper_moons_3).reload.owned?

    follow_redirect!
    assert_select ".alert form[action=?]", comic_path(issue)
  end

  test "remove takes an issue out of your stash, and only yours" do
    assert_difference -> { users(:ricardo).collection_items.count } => -1, -> { users(:ada).collection_items.count } => 0 do
      patch comic_path(issues(:paper_moons_1)), params: { comic: { owned: "false" } }
    end
  end

  test "an issue goes on the hunt list, shows on Find the gaps, and comes off again" do
    issue = issues(:night_signal_1)
    post comic_hunt_path(issue)
    assert users(:ricardo).hunted_issues.include?(issue)

    get gaps_path
    assert_select "details.cs-gap-group h2", "Night Signal"

    delete comic_hunt_path(issue)
    assert_not users(:ricardo).hunted_issues.include?(issue)
  end

  test "the hunt button posts, or deletes once the issue is on the list" do
    get comic_path(issues(:paper_moons_3))
    assert_select "form[action=?] input[name=_method][value=delete]", comic_hunt_path(issues(:paper_moons_3))

    get comic_path(issues(:night_signal_1))
    assert_select "form[action=?] input[name=_method][value=delete]", comic_hunt_path(issues(:night_signal_1)), count: 0
    assert_select "form[action=?] button[aria-pressed=false]", comic_hunt_path(issues(:night_signal_1))
  end

  test "an unknown issue is a 404" do
    post comic_hunt_path(999_999)
    assert_response :not_found
  end
end
