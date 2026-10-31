require "test_helper"

# View issue: one comic in full. Sample comics used here (SampleStash.comics_list):
#   1 = Night Signal #53 (missing)   2 = Night Signal #52 (missing, "Lights Out, Part 4")
#   3 = Night Signal #48 (owned)
class ViewIssueTest < ActionDispatch::IntegrationTest
  test "an owned issue shows its details and a remove button" do
    get comic_path(3)
    assert_response :success
    assert_select "title", "Night Signal #48 · Comic Stash"
    assert_select "h1", "Night Signal #48"
    assert_select "nav[aria-label=Breadcrumb] a[href=?]", comics_path(series: "Night Signal")
    assert_select "section[aria-label='Your copy']", /In your stash/
    assert_select "form[action=?] input[name=_method][value=patch]", comic_path(3)
    assert_select "button", /Remove from collection/
  end

  test "a missing issue offers Got it and the hunt list, and says where it fits" do
    get comic_path(2)
    assert_select "section[aria-label='Your copy']", /Fills the gap between #48 and #53/
    assert_select "button", /Got it/
    assert_select "button[data-controller=hunt-button]"
  end

  test "previous and next link to the neighbouring issues in the series" do
    get comic_path(2)
    assert_select "nav[aria-label='Issues in this series'] a[rel=prev][href=?]", comic_path(3)
    assert_select "nav[aria-label='Issues in this series'] a[rel=next][href=?]", comic_path(1)
  end

  test "the story arc is read from the title" do
    get comic_path(2)
    assert_select ".cs-facts dd", /Lights Out/
  end

  test "an unknown comic is a 404 page, not an error" do
    get comic_path(999)
    assert_response :not_found
  end

  test "Got it marks the comic as owned and comes back to the issue" do
    patch comic_path(2), params: { comic: { owned: "true" } }
    assert_redirected_to comic_path(2)
    follow_redirect!
    assert_select ".alert", /Night Signal #52 is in your stash/
  end
end
