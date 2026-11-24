require "test_helper"

# Ada owns Paper Moons #1 (fixtures). The catalogue has Paper Moons Vol. 2
# (#1-#5) and Night Signal (#1).
class AddComicsServiceTest < ActiveSupport::TestCase
  setup { @adder = AddComics.new(users(:ada)) }

  test "adds an issue the catalogue already has" do
    assert_no_difference [ "Series.count", "Issue.count" ] do
      item = @adder.add(series_name: "Paper Moons Vol. 2", number: "#2")
      assert_equal issues(:paper_moons_2), item.issue
      assert item.owned?
    end
  end

  test "makes the series and issue when the catalogue hasn't got them" do
    assert_difference -> { Series.count } => 1, -> { Issue.count } => 1 do
      @adder.add(series_name: "Brand New Comic", number: "1", barcode: "76194134182500111")
    end
    issue = Series.find_by!(name: "Brand New Comic").issues.sole
    assert_equal "76194134182500111", issue.upc
    assert issue.released?
  end

  test "series names match whatever the capitals" do
    assert_no_difference("Series.count") { @adder.add(series_name: "night signal", number: "1") }
  end

  test "a range adds every issue in one go" do
    result = @adder.add_all(AddComics.range("Night Signal", "1", "5"))
    assert_empty result.problems
    assert_equal 5, result.added.size
    assert_equal %w[1 2 3 4 5], users(:ada).owned_issues.where(series: series(:night_signal)).in_order.pluck(:number)
  end

  test "a pasted list can mix series, and barcodes are optional" do
    rows = AddComics.parse_lines("Night Signal, 2\n\nPaper Moons Vol. 2, 3, 76194134182500311\n")
    assert_equal 2, @adder.add_all(rows).added.size
    assert_equal "76194134182500311", issues(:paper_moons_3).reload.upc
  end

  test "a CSV has a header row, then series and issue columns" do
    rows = AddComics.parse_csv("series,issue,barcode\nNight Signal,2,\nNight Signal,3,\n")
    assert_equal %w[2 3], rows.map(&:number)
    assert_equal 2, @adder.add_all(rows).added.size
  end

  test "one bad line means nothing is added" do
    result = nil
    assert_no_difference("CollectionItem.count") do
      result = @adder.add_all(AddComics.parse_lines("Night Signal, 2\nNight Signal\n"))
    end
    assert_equal [ "Line 2: needs a series name and an issue number." ], result.problems
  end

  test "an empty or backwards range has nothing to add" do
    assert_equal [ "Nothing to add." ], @adder.add_all(AddComics.range("Night Signal", "5", "1")).problems
  end

  test "more than 500 at once is too many" do
    assert_match "more than 500", @adder.add_all(AddComics.range("Night Signal", "1", "600")).problems.first
  end
end
