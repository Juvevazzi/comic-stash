# Your stash: which issues each user owns or is hunting for.
class CreateCollectionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.integer :status, null: false, default: 0 # 0 = owned, 1 = hunting
      t.text :notes

      t.timestamps
    end
    # You can't have the same issue twice, even with a double-click.
    add_index :collection_items, [ :user_id, :issue_id ], unique: true
    add_index :collection_items, [ :user_id, :status ]
    add_check_constraint :collection_items, "status IN (0, 1)", name: "collection_items_status_known"
  end
end
