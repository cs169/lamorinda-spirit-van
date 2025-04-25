class AddAccessibilityFieldsToRidesAndPassengers < ActiveRecord::Migration[7.2]
  def change
    change_table :rides do |t|
      t.string  :address_name, null: true
      t.text    :notes_about_location, null: true
      t.string  :destination_type
      t.boolean :wheelchair, default: false, null: false
      t.boolean :new_passenger, default: false, null: false
      t.boolean :low_income, default: false, null: false
      t.boolean :disabled, default: false, null: false
      t.boolean :need_caregiver, default: false, null: false
    end

    change_table :passengers do |t|
      t.boolean :wheelchair, default: false, null: false
      t.boolean :new_passenger, default: false, null: false
      t.boolean :low_income, default: false, null: false
      t.boolean :disabled, default: false, null: false
      t.boolean :need_caregiver, default: false, null: false
    end
  end
end
