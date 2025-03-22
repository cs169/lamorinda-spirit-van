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

ActiveRecord::Schema[7.2].define(version: 2025_03_20_232838) do
  create_table "addresses", force: :cascade do |t|
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["street", "city", "state", "zip"], name: "index_addresses_on_full_address", unique: true
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["address_id"], name: "index_passengers_on_address_id"
  end

  create_table "rides", force: :cascade do |t|
    t.date "date", null: false
    t.integer "van"
    t.float "hours"
    t.decimal "amount_paid", precision: 10, scale: 2
    t.text "notes_date_reserved"
    t.text "confirmed_with_passenger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passenger_id"
    t.integer "driver_id"
    t.text "notes"
    t.binary "emailed_driver"
    t.integer "start_address_id"
    t.integer "dest_address_id"
    t.index ["driver_id"], name: "index_rides_on_driver_id"
    t.index ["passenger_id"], name: "index_rides_on_passenger_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.date "shift_date"
    t.string "shift_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "driver_id", null: false
    t.integer "van"
    t.string "pu_time"
    t.string "do_time"
    t.string "odo_pre"
    t.string "odo_pst"
    t.index ["driver_id"], name: "index_shifts_on_driver_id"
  end

  add_foreign_key "passengers", "addresses"
  add_foreign_key "rides", "drivers"
  add_foreign_key "rides", "passengers"
  add_foreign_key "shifts", "drivers"
end
