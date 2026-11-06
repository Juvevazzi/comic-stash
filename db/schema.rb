# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_05_193444) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "collection_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "issue_id", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_collection_items_on_issue_id"
    t.index ["user_id", "issue_id"], name: "index_collection_items_on_user_id_and_issue_id", unique: true
    t.index ["user_id", "status"], name: "index_collection_items_on_user_id_and_status"
    t.index ["user_id"], name: "index_collection_items_on_user_id"
    t.check_constraint "status = ANY (ARRAY[0, 1])", name: "collection_items_status_known"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "series_id", null: false
    t.string "number", null: false
    t.decimal "sort_number", precision: 10, scale: 3
    t.string "title"
    t.date "cover_date"
    t.date "store_date"
    t.decimal "price", precision: 8, scale: 2
    t.integer "page_count"
    t.string "upc"
    t.string "isbn"
    t.text "description"
    t.string "image_url"
    t.jsonb "credits", default: [], null: false
    t.jsonb "characters", default: [], null: false
    t.integer "metron_id"
    t.datetime "metron_modified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metron_id"], name: "index_issues_on_metron_id", unique: true
    t.index ["series_id", "number"], name: "index_issues_on_series_id_and_number", unique: true
    t.index ["series_id", "sort_number"], name: "index_issues_on_series_id_and_sort_number"
    t.index ["series_id"], name: "index_issues_on_series_id"
    t.index ["upc"], name: "index_issues_on_upc"
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name", null: false
    t.integer "metron_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metron_id"], name: "index_publishers_on_metron_id", unique: true
  end

  create_table "series", force: :cascade do |t|
    t.bigint "publisher_id"
    t.string "name", null: false
    t.string "sort_name", null: false
    t.integer "volume"
    t.integer "year_began"
    t.integer "year_end"
    t.string "series_type"
    t.string "status"
    t.integer "issue_count"
    t.text "description"
    t.integer "metron_id"
    t.datetime "metron_modified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metron_id"], name: "index_series_on_metron_id", unique: true
    t.index ["publisher_id"], name: "index_series_on_publisher_id"
    t.index ["sort_name"], name: "index_series_on_sort_name"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "password_changed_at"
    t.string "appearance", default: "system", null: false
    t.string "currency", default: "EUR", null: false
    t.boolean "show_prices", default: true, null: false
    t.boolean "count_variants", default: false, null: false
    t.boolean "new_issues", default: true, null: false
    t.boolean "hunt_reminder", default: true, null: false
    t.boolean "monthly_report", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "collection_items", "issues"
  add_foreign_key "collection_items", "users"
  add_foreign_key "issues", "series"
  add_foreign_key "series", "publishers"
  add_foreign_key "sessions", "users"
end
