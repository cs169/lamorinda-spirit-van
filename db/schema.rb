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

ActiveRecord::Schema[7.2].define(version: 2025_02_24_022846) do
  create_table "rides", force: :cascade do |t|
    t.string "day", null: false
    t.date "date", null: false
    t.text "driver"
    t.integer "van"
    t.text "passenger_name_and_phone"
    t.text "passenger_address"
    t.text "destination"
    t.text "notes_to_driver"
    t.string "driver_initials"
    t.float "hours"
    t.decimal "amount_paid", precision: 10, scale: 2
    t.integer "ride_count"
    t.string "c"
    t.text "notes_date_reserved"
    t.text "confirmed_with_passenger"
    t.string "driver_email"
  end
end
