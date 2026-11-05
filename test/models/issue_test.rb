require "test_helper"

class IssueTest < ActiveSupport::TestCase
  def sort_number_for(number)
    issue = Issue.new(series: series(:night_signal), number: number)
    issue.validate
    issue.sort_number
  end

  test "needs a number, without the #" do
    assert_not Issue.new(series: series(:paper_moons), number: " ").valid?
    assert_equal "7", Issue.new(number: " #7 ").number
  end

  test "a number appears once per series, but can repeat in another series" do
    assert_not Issue.new(series: series(:paper_moons), number: "1").valid?
    assert Issue.new(series: series(:night_signal), number: "2").valid?
  end

  test "works out a sort number from the issue number" do
    assert_equal 12, sort_number_for("12")
    assert_equal 1.5, sort_number_for("1.5")
    assert_nil sort_number_for("½")
  end

  test "in_order puts 2 before 10" do
    series(:night_signal).issues.create!(number: "10")
    series(:night_signal).issues.create!(number: "2")
    assert_equal %w[1 2 10], series(:night_signal).issues.in_order.pluck(:number)
  end

  test "released leaves out issues that aren't out yet" do
    assert_equal %w[1 2 3 4], series(:paper_moons).issues.released.in_order.pluck(:number)
    assert issues(:paper_moons_1).released?
    assert_not issues(:paper_moons_5).released?
  end

  test "released falls back to the cover date" do
    assert_includes Issue.released, issues(:night_signal_1)
  end

  test "labels and names itself like a collector would" do
    assert_equal "#3", issues(:paper_moons_3).label
    assert_equal "Paper Moons Vol. 2 #3", issues(:paper_moons_3).to_s
  end
end
