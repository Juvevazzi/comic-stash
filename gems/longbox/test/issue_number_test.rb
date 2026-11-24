require_relative "test_helper"

class IssueNumberTest < Minitest::Test
  def sorted(*numbers) = numbers.map { |n| Longbox::IssueNumber.new(n) }.sort.map(&:to_s)

  def test_sorts_like_numbers_not_text
    assert_equal %w[1 2 10], sorted("10", "2", "1")
  end

  def test_decimals_sit_between_whole_numbers
    assert_equal %w[1 1.5 2], sorted("2", "1.5", "1")
  end

  def test_numbers_without_digits_go_last
    assert_equal %w[0 1 ½], sorted("½", "1", "0")
  end

  def test_ignores_a_leading_hash_and_spaces
    assert_equal "7", Longbox::IssueNumber.new(" #7 ").to_s
  end

  def test_the_same_text_is_the_same_issue
    assert_equal 1, [ Longbox::IssueNumber.new("3"), Longbox::IssueNumber.new(3) ].uniq.size
  end

  def test_rejects_a_blank_number
    assert_raises(ArgumentError) { Longbox::IssueNumber.new(" ") }
  end
end
