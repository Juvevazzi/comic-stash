require "test_helper"

class CollectionItemTest < ActiveSupport::TestCase
  test "one copy of an issue per user" do
    copy = CollectionItem.new(user: users(:ricardo), issue: issues(:paper_moons_1))
    assert_not copy.valid?
    assert_includes copy.errors[:issue_id], "is already in your stash"
  end

  test "another user can own the same issue" do
    assert CollectionItem.new(user: users(:ada), issue: issues(:paper_moons_2)).valid?
  end

  test "new items are owned unless they say otherwise" do
    assert CollectionItem.new.owned?
  end

  test "status must be owned or hunting" do
    assert_not CollectionItem.new(user: users(:ada), issue: issues(:paper_moons_2), status: "lost").valid?
  end

  test "got it moves an issue from the hunt list into the stash" do
    item = collection_items(:ricardo_paper_moons_3)
    item.owned!
    assert item.reload.owned?
  end
end
