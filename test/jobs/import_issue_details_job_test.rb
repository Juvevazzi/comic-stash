require "test_helper"

class ImportIssueDetailsJobTest < ActiveJob::TestCase
  teardown { MetronImport.client = nil }

  test "fills in the issue's details from Metron" do
    MetronImport.client = FakeMetron.new
    issue = series(:night_signal).issues.create!(number: "2", metron_id: 9001)
    assert issue.needs_details?

    ImportIssueDetailsJob.perform_now(issue)
    assert_equal "The First Pane", issue.reload.title
    assert_not issue.needs_details?
  end

  test "gives up quietly on an issue Metron doesn't have" do
    MetronImport.client = FakeMetron.new(error: Longbox::Metron::NotFound.new("gone"))
    assert_nothing_raised { ImportIssueDetailsJob.perform_now(issues(:paper_moons_2)) }
  end
end
