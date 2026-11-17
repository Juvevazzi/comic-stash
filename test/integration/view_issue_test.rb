require "test_helper"

# View issue, from the fixtures: Ricardo owns Paper Moons #1 (which has its
# Metron details), #2 and #4, and is hunting #3.
class ViewIssueTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { sign_in_as users(:ricardo) }

  test "an owned issue shows its details and a remove button" do
    issue = issues(:paper_moons_1)
    get comic_path(issue)
    assert_response :success
    assert_select "title", "Paper Moons Vol. 2 #1 · Comic Stash"
    assert_select "h1", "Paper Moons Vol. 2 #1"
    assert_select "nav[aria-label=Breadcrumb] a[href=?]", comics_path(series: series(:paper_moons).id)
    assert_select "section[aria-label='Your copy']", /In your stash/
    assert_select "form[action=?] input[name=_method][value=patch]", comic_path(issue)
    assert_select "button", /Remove from collection/
  end

  test "creators and characters come from Metron's credits" do
    get comic_path(issues(:paper_moons_1))
    assert_select ".cs-credits dd", "Ines Varga"
    assert_select ".cs-credits", /Ines Varga and Kit Hale/
    assert_select "details.cs-disclosure dd", "June Park"
    assert_select ".cs-chips", /Juno Vale/
  end

  test "a missing issue offers Got it and the hunt list, and says where it fits" do
    get comic_path(issues(:paper_moons_3))
    assert_select "section[aria-label='Your copy']", /Fills the gap between #2 and #4/
    assert_select "button", /Got it/
    assert_select "button[data-controller=hunt-button][aria-pressed=true]"
  end

  test "previous and next link to the neighbouring issues in the series" do
    get comic_path(issues(:paper_moons_3))
    assert_select "nav[aria-label='Issues in this series'] a[rel=prev][href=?]", comic_path(issues(:paper_moons_2))
    assert_select "nav[aria-label='Issues in this series'] a[rel=next][href=?]", comic_path(issues(:paper_moons_4))
  end

  test "an issue without its details queues a Metron import, once it's opened" do
    assert_enqueued_with(job: ImportIssueDetailsJob, args: [ issues(:paper_moons_2) ]) do
      get comic_path(issues(:paper_moons_2))
    end
    assert_select ".alert-info", /Fetching the credits/
  end

  test "an issue that has its details doesn't queue anything" do
    assert_no_enqueued_jobs(only: ImportIssueDetailsJob) { get comic_path(issues(:paper_moons_1)) }
  end

  test "an unknown comic is a 404 page, not an error" do
    get comic_path(999_999)
    assert_response :not_found
  end

  test "Got it comes back to the issue with a message" do
    issue = issues(:paper_moons_3)
    patch comic_path(issue), params: { comic: { owned: "true" } }
    assert_redirected_to comic_path(issue)
    follow_redirect!
    assert_select ".alert", /Paper Moons Vol. 2 #3 is in your stash/
  end
end
