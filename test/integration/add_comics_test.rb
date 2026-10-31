require "test_helper"

# Add comics: the page has every part of its wireframe, and the stub
# actions answer the way the real ones will (redirect back with a message).
class AddComicsTest < ActionDispatch::IntegrationTest
  test "shows the one-comic form, Added just now and the bulk tabs" do
    get new_comic_path
    assert_response :success
    assert_select "form[action=?]", comics_path do
      assert_select "input[name=?][required][list=series-options]", "comic[series_name]"
      assert_select "input[name=?][required][pattern]", "comic[issue_number]"
      assert_select "input[name=?]:not([required])", "comic[barcode]"
    end
    assert_select "datalist#series-options option", SampleStash.series_options.size
    assert_select "section[aria-labelledby=added-h] li", SampleStash.just_added.size
    assert_select "[role=tab]", 3
    assert_select "[role=tab][aria-selected=true]", "Issue range"
    assert_select "[role=tabpanel][hidden]", 2
  end

  test "adding a comic confirms it and keeps the series filled in" do
    post comics_path, params: { comic: { series_name: "Paper Moons", issue_number: "23", barcode: "" } }
    assert_redirected_to new_comic_path(series: "Paper Moons")

    follow_redirect!
    assert_select ".alert-success", /Paper Moons #23 is in your collection/
    assert_select "input[name=?][value=?]", "comic[series_name]", "Paper Moons"
  end

  test "a request without the comic fields is rejected" do
    post comics_path, params: { something: "else" }
    assert_response :bad_request
  end

  test "bulk add and undo come back to Add comics" do
    post bulk_comics_path, params: { bulk: { source: "range", series_name: "Hollow Crown", from: "2", to: "8" } }
    assert_redirected_to new_comic_path

    delete comic_path(1)
    assert_redirected_to new_comic_path
  end
end
