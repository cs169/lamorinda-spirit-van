class Createrides < ActiveRecord::Migration[7.2]
  def change
    create_table :rides do |t|
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
end
