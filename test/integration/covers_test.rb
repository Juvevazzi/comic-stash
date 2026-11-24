require "test_helper"

# Real covers from Metron. Paper Moons #1 gets a cover in setup; the other
# fixture issues have none, so they keep the halftone placeholder.
class CoversTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper # View issue queues a Metron job; this keeps it in the test queue

  COVER = "https://static.metron.cloud/media/issue/pm1.jpg".freeze

  setup do
    sign_in_as users(:ricardo)
    issues(:paper_moons_1).update!(image_url: COVER)
  end

  test "View issue shows the cover from Metron" do
    get comic_path(issues(:paper_moons_1))
    assert_select ".cs-issue-cover img[src=?]", COVER
  end

  test "an issue without a cover keeps the placeholder" do
    get comic_path(issues(:paper_moons_2))
    assert_select ".cs-issue-cover img", 0
    assert_select ".cs-issue-cover .cs-cover-placeholder"
  end

  test "the lists use real covers too" do
    [ dashboard_path, series_index_path, comics_path, gaps_path ].each do |path|
      get path
      assert_select "img[src=?]", COVER, { minimum: 1 }, "#{path} should show the cover"
    end
  end
end
