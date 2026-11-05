# A series (one run of a title, e.g. Paper Moons Vol. 2). Shared by every user.
class CreateSeries < ActiveRecord::Migration[8.1]
  def change
    create_table :series do |t|
      # No null: false: a series you type in yourself may not have a publisher yet.
      t.references :publisher, foreign_key: true
      t.string :name, null: false
      t.string :sort_name, null: false # "Long Box Kids" for "The Long Box Kids"
      t.integer :volume
      t.integer :year_began
      t.integer :year_end
      t.string :series_type # "Ongoing series", "Limited series"...
      t.string :status      # "Publishing", "Ended"...
      t.integer :issue_count
      t.text :description
      t.integer :metron_id
      t.datetime :metron_modified_at

      t.timestamps
    end
    add_index :series, :metron_id, unique: true
    add_index :series, :sort_name
  end
end
