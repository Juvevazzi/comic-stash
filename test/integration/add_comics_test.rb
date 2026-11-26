require "test_helper"

# Add comics: one comic, the three bulk forms and Undo, all saving to the
# logged-in user's stash. The catalogue has Paper Moons Vol. 2 (#1-#5) and
# Night Signal (#1); Ricardo collects Paper Moons.
class AddComicsTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:ricardo) }

  test "shows the one-comic form, Added just now and the bulk tabs" do
    get new_comic_path
    assert_response :success
    assert_select "form[action=?]", comics_path do
      assert_select "input[name=?][required][list=series-options]", "comic[series_name]"
      assert_select "input[name=?][required][pattern]", "comic[issue_number]"
      assert_select "input[name=?]:not([required])", "comic[barcode]"
    end
    assert_select "datalist#series-options option", 2 # Paper Moons (collected) + Night Signal (catalogue)
    assert_select "datalist#series-options option[value=?]", series(:night_signal).display_name, text: "In the catalogue"
    assert_select "section[aria-labelledby=added-h] li", users(:ricardo).collection_items.count
    assert_select "[role=tab]", 3
    assert_select "[role=tab][aria-selected=true]", "Issue range"
    assert_select "[role=tabpanel][hidden]", 2
  end

  test "adding a comic saves it and keeps the series filled in" do
    assert_difference -> { users(:ricardo).collection_items.count }, 1 do
      post comics_path, params: { comic: { series_name: "Night Signal", issue_number: "2", barcode: "" } }
    end
    assert_redirected_to new_comic_path(series: "Night Signal")

    follow_redirect!
    assert_select ".alert-success", /Night Signal #2 is in your collection/
    assert_select "input[name=?][value=?]", "comic[series_name]", "Night Signal"
  end

  test "a comic that can't be saved says why and adds nothing" do
    assert_no_difference -> { CollectionItem.count } do
      post comics_path, params: { comic: { series_name: "", issue_number: "2" } }
    end
    follow_redirect!
    assert_select ".alert-danger", /Nothing was added: Name can't be blank/
  end

  test "a request without the comic fields is rejected" do
    post comics_path, params: { something: "else" }
    assert_response :bad_request
  end

  test "an issue range adds every issue" do
    assert_difference -> { users(:ricardo).collection_items.count }, 3 do
      post bulk_comics_path, params: { bulk: { source: "range", series_name: "Night Signal", from: "2", to: "4" } }
    end
    follow_redirect!
    assert_select ".alert-success", /Added 3 comics/
  end

  test "a CSV upload adds every row" do
    assert_difference -> { users(:ricardo).collection_items.count }, 2 do
      post bulk_comics_path, params: { bulk: { source: "csv", file: fixture_file_upload("comics.csv", "text/csv") } }
    end
  end

  test "a pasted list with a bad line adds nothing and names the line" do
    assert_no_difference -> { CollectionItem.count } do
      post bulk_comics_path, params: { bulk: { source: "paste", list: "Night Signal, 2\nNight Signal" } }
    end
    follow_redirect!
    assert_select ".alert-danger", /Line 2: needs a series name and an issue number/
  end

  test "undo takes back what you just added" do
    assert_difference -> { users(:ricardo).collection_items.count }, -1 do
      delete comic_path(issues(:paper_moons_1))
    end
    assert_redirected_to new_comic_path
  end
end
