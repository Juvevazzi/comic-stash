require "test_helper"

class ImportSeriesJobTest < ActiveJob::TestCase
  teardown { MetronImport.client = nil }

  test "imports the series" do
    MetronImport.client = FakeMetron.new
    assert_difference("Series.count") { ImportSeriesJob.perform_now(501) }
  end

  test "tries again later when Metron's rate limit is reached" do
    MetronImport.client = FakeMetron.new(error: Longbox::Metron::RateLimited.new(retry_after: 30))
    assert_enqueued_with(job: ImportSeriesJob, args: [ 501 ]) { ImportSeriesJob.perform_now(501) }
  end

  test "gives up quietly on a series Metron doesn't have" do
    MetronImport.client = FakeMetron.new(error: Longbox::Metron::NotFound.new("gone"))
    assert_no_enqueued_jobs { ImportSeriesJob.perform_now(501) }
  end
end