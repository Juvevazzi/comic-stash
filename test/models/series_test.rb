require "test_helper"

class SeriesTest < ActiveSupport::TestCase
  test "needs a name" do
    assert_not Series.new(name: "").valid?
  end

  test "files 'The' titles under the next word" do
    series = Series.new(name: "The Long Box Kids")
    series.validate
    assert_equal "Long Box Kids", series.sort_name
  end

  test "can't end before it began" do
    series = Series.new(name: "Glasshouse", year_began: 2024, year_end: 2023)
    assert_not series.valid?
    assert series.errors.key?(:year_end)
  end

  test "a Metron id belongs to one series only" do
    assert_not Series.new(name: "Copy", metron_id: series(:paper_moons).metron_id).valid?
  end

  test "alphabetical goes by sort name" do
    Series.create!(name: "The Long Box Kids")
    assert_equal [ "Long Box Kids", "Night Signal", "Paper Moons" ], Series.alphabetical.pluck(:sort_name)
  end

  test "shows the volume after volume 1" do
    assert_equal "Paper Moons Vol. 2", series(:paper_moons).display_name
    assert_equal "Night Signal", series(:night_signal).display_name
  end

  test "deleting a series deletes its issues and everyone's copies of them" do
    assert_difference -> { Issue.count } => -5, -> { CollectionItem.count } => -5 do
      series(:paper_moons).destroy
    end
  end
end
