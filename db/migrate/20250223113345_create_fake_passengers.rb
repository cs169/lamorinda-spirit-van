class CreateFakePassengers < ActiveRecord::Migration[7.2]
  def change
    create_table :passengers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :full_name, null: false
      t.string :address, null: false
      t.string :city, null: false
      t.string :state, default: "CA"
      t.string :zip
      t.string :phone
      t.string :alternative_phone
      t.date :birthday
      t.integer :race
      t.string :hispanic
      t.string :email
      t.text :notes
      t.date :date_registered
      t.text :audit

      t.timestamps
    end
  end
end
