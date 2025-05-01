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

ActiveRecord::Schema[7.2].define(version: 2025_04_27_231410) do
  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["street", "city", "state", "zip"], name: "index_addresses_on_full_address", unique: true
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.integer "user_id"
    t.integer "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer "dashboard_id"
    t.integer "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.integer "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "companion"
    t.string "mobility"
    t.string "note"
    t.string "pick_up_time"
    t.string "drop_off_time"
    t.decimal "fare", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ride_id", null: false
    t.index ["ride_id"], name: "index_feedbacks_on_ride_id"
  end

  create_table "passengers", force: :cascade do |t|
    t.string "phone"
    t.string "alternative_phone"
    t.integer "race"
    t.string "email"
    t.text "notes"
    t.text "audit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.string "name"
    t.datetime "birthday"
    t.binary "hispanic"
    t.datetime "date_registered"
    t.boolean "wheelchair", default: false, null: false
    t.boolean "low_income", default: false, null: false
    t.boolean "disabled", default: false, null: false
    t.boolean "need_caregiver", default: false, null: false
    t.index ["address_id"], name: "index_passengers_on_address_id"
  end

  create_table "rides", force: :cascade do |t|
    t.float "hours"
    t.decimal "amount_paid", precision: 10, scale: 2
    t.text "notes_date_reserved"
    t.text "confirmed_with_passenger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passenger_id"
    t.text "notes"
    t.integer "start_address_id"
    t.integer "dest_address_id"
    t.string "address_name"
    t.text "notes_about_location"
    t.string "destination_type"
    t.boolean "wheelchair", default: false, null: false
    t.boolean "low_income", default: false, null: false
    t.boolean "disabled", default: false, null: false
    t.boolean "need_caregiver", default: false, null: false
    t.integer "next_ride_id"
    t.integer "shift_id"
    t.index ["next_ride_id"], name: "index_rides_on_next_ride_id"
    t.index ["passenger_id"], name: "index_rides_on_passenger_id"
    t.index ["shift_id"], name: "index_rides_on_shift_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.string "shift_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_id", null: false
    t.integer "van"
    t.string "pick_up_time"
    t.string "drop_off_time"
    t.string "odometer_pre"
    t.string "odometer_post"
    t.text "notes"
    t.date "date"
    t.binary "emailed_driver"
    t.index ["driver_id"], name: "index_shifts_on_driver_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "feedbacks", "rides"
  add_foreign_key "passengers", "addresses"
  add_foreign_key "rides", "passengers"
  add_foreign_key "rides", "rides", column: "next_ride_id"
  add_foreign_key "rides", "shifts"
  add_foreign_key "shifts", "drivers"
end
