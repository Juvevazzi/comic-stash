# Accounts: who you are, how you log in, and the Preferences and
# Notifications settings from your profile page.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.datetime :password_changed_at

      # Preferences on the profile page
      t.string :appearance, null: false, default: "system"
      t.string :currency, null: false, default: "EUR"
      t.boolean :show_prices, null: false, default: true
      t.boolean :count_variants, null: false, default: false

      # Notifications on the profile page
      t.boolean :new_issues, null: false, default: true
      t.boolean :hunt_reminder, null: false, default: true
      t.boolean :monthly_report, null: false, default: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
