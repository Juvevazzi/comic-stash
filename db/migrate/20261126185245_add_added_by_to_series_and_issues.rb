class AddAddedByToSeriesAndIssues < ActiveRecord::Migration[8.1]
  def up
    add_reference :series, :added_by, foreign_key: { to_table: :users, on_delete: :cascade }
    add_reference :issues, :added_by, foreign_key: { to_table: :users, on_delete: :cascade }

    # One issue number per series in the catalogue, and one per series per user
    # for private issues. (A plain unique index would clash between users.)
    remove_index :issues, [ :series_id, :number ]
    add_index :issues, [ :series_id, :number ], unique: true, where: "added_by_id IS NULL",
              name: "index_catalogue_issues_on_series_and_number"
    add_index :issues, [ :series_id, :number, :added_by_id ], unique: true, where: "added_by_id IS NOT NULL",
              name: "index_private_issues_on_series_number_and_user"

    # Existing hand-added rows (no metron_id) collected by exactly one person
    # become that person's. Rows several people collect stay in the catalogue.
    execute <<~SQL
      UPDATE issues SET added_by_id = owners.user_id
      FROM (SELECT issue_id, MIN(user_id) AS user_id FROM collection_items
            GROUP BY issue_id HAVING COUNT(DISTINCT user_id) = 1) owners
      WHERE issues.id = owners.issue_id AND issues.metron_id IS NULL;

      UPDATE series SET added_by_id = owners.user_id
      FROM (SELECT i.series_id, MIN(ci.user_id) AS user_id
            FROM issues i JOIN collection_items ci ON ci.issue_id = i.id
            GROUP BY i.series_id HAVING COUNT(DISTINCT ci.user_id) = 1) owners
      WHERE series.id = owners.series_id AND series.metron_id IS NULL;
    SQL
  end

  def down
    remove_index :issues, name: "index_private_issues_on_series_number_and_user"
    remove_index :issues, name: "index_catalogue_issues_on_series_and_number"
    add_index :issues, [ :series_id, :number ], unique: true
    remove_reference :issues, :added_by
    remove_reference :series, :added_by
  end
end
