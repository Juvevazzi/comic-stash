# One issue of a series, e.g. Paper Moons #7. Shared by every user.
class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.references :series, null: false, foreign_key: true
      t.string :number, null: false # text: "7", "1.5", "½"
      t.decimal :sort_number, precision: 10, scale: 3 # 7.0, 1.5, nil, for ORDER BY
      t.string :title
      t.date :cover_date
      t.date :store_date
      t.decimal :price, precision: 8, scale: 2
      t.integer :page_count
      t.string :upc
      t.string :isbn
      t.text :description
      t.string :image_url
      # Shown on View issue and searched as text, so no separate tables.
      t.jsonb :credits, null: false, default: []
      t.jsonb :characters, null: false, default: []
      t.integer :metron_id
      t.datetime :metron_modified_at

      t.timestamps
    end
    add_index :issues, [ :series_id, :number ], unique: true
    add_index :issues, [ :series_id, :sort_number ]
    add_index :issues, :metron_id, unique: true
    add_index :issues, :upc
  end
end
