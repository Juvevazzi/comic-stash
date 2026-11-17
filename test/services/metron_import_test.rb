require "test_helper"

class MetronImportTest < ActiveSupport::TestCase
  def import = MetronImport.new(client: FakeMetron.new)

  test "imports a new series with all its issues" do
    series = assert_difference -> { Series.count } => 1, -> { Issue.count } => 3 do
      import.import_series(501)
    end

    assert_equal "Glasshouse", series.name
    assert_equal "Limited Series", series.series_type
    assert_equal 2023, series.year_began
    assert_equal %w[1 2 3], series.issues.in_order.pluck(:number)
    assert_equal Date.new(2022, 12, 14), series.issues.find_by(number: "1").store_date
  end

  test "reuses a publisher it already has" do
    assert_no_difference("Publisher.count") { import.import_series(501) }
    assert_equal publishers(:lantern), Series.find_by(metron_id: 501).publisher
  end

  test "importing again updates the series instead of copying it" do
    import.import_series(501)
    Series.find_by(metron_id: 501).update!(name: "Renamed by hand")

    assert_no_difference [ "Series.count", "Issue.count" ] do
      import.import_series(501)
    end
    assert_equal "Glasshouse", Series.find_by(metron_id: 501).name
  end

  test "re-importing keeps everyone's stash" do
    import.import_series(501)
    issue = Issue.find_by(metron_id: 9001)
    users(:ricardo).collection_items.create!(issue: issue)

    import.import_series(501)
    assert users(:ricardo).owned_issues.exists?(issue.id)
  end

  test "issue details fill in the title, credits, characters and price" do
    import.import_series(501)
    issue = import.import_issue_details(Issue.find_by(metron_id: 9001))

    assert_equal "The First Pane", issue.title
    assert_equal [ { "name" => "Ines Varga", "roles" => %w[Writer Artist] },
                   { "name" => "Kit Hale", "roles" => %w[Cover] } ], issue.credits
    assert_equal [ "Juno Vale" ], issue.characters
    assert_equal BigDecimal("3.99"), issue.price
    assert_equal 32, issue.page_count
  end

  test "a Metron error leaves the catalogue as it was" do
    failing = MetronImport.new(client: FakeMetron.new(error: Longbox::Metron::ServerError.new("down")))
    assert_no_difference [ "Series.count", "Issue.count" ] do
      assert_raises(Longbox::Metron::ServerError) { failing.import_series(501) }
    end
  end
end