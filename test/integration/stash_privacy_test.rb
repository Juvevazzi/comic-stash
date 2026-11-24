require "test_helper"
require "csv"

# One stash never leaks into another. Ada is logged in. The fixtures give
# Ricardo Paper Moons #1, #2 and #4 plus a hunt for #3, and give Ada only #1.
# Every test checks that Ada sees and changes her own stash and nothing of
# Ricardo's: the rule from 23.2, written down as tests.
class StashPrivacyTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper # View issue queues a Metron job; this keeps it in the test queue

  setup { sign_in_as users(:ada) }

  test "Find the gaps shows Ada's gaps, not Ricardo's hunt list" do
    get gaps_path
    assert_select "table.cs-gap-table tbody tr", 3 # Paper Moons #2, #3 and #4

    get gaps_path(hunt: "1")
    assert_select "table.cs-gap-table tbody tr", 0 # Ricardo hunts #3, Ada hunts nothing
  end

  test "View issue shows Ada's copy, not Ricardo's" do
    get comic_path(issues(:paper_moons_3))
    assert_select ".cs-your-copy", /Missing from your stash/
    assert_select ".cs-your-copy button[aria-pressed=true]", 0
  end

  test "the CSV export has only Ada's statuses" do
    get profile_export_path(format: :csv)
    statuses = CSV.parse(response.body, headers: true).map { |row| row["Status"] }
    assert_equal %w[owned missing missing missing], statuses
  end

  test "Remove, Undo and taking off the hunt list never touch Ricardo's rows" do
    assert_no_difference -> { users(:ricardo).collection_items.count } do
      patch comic_path(issues(:paper_moons_2)), params: { comic: { owned: "false" } } # Remove
      delete comic_path(issues(:paper_moons_4)) # Undo
      delete comic_hunt_path(issues(:paper_moons_3)) # Take off the hunt list
    end
  end

  test "Got it on an issue Ricardo is hunting gives Ada her own copy" do
    patch comic_path(issues(:paper_moons_3)), params: { comic: { owned: "true" } }
    assert users(:ada).owned_issues.include?(issues(:paper_moons_3))
    assert collection_items(:ricardo_paper_moons_3).reload.hunting?
  end
end
