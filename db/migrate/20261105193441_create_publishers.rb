# Comic publishers, e.g. Lantern Press. Shared by every user.
class CreatePublishers < ActiveRecord::Migration[8.1]
  def change
    create_table :publishers do |t|
      t.string :name, null: false
      t.integer :metron_id

      t.timestamps
    end
    add_index :publishers, :metron_id, unique: true
  end
end
