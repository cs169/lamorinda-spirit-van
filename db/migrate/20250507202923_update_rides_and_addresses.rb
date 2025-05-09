class UpdateRidesAndAddresses < ActiveRecord::Migration[7.2]
  def change
    # === Rides table changes ===
    remove_column :rides, :address_name, :string
    remove_column :rides, :notes_about_location, :text
    remove_column :rides, :date, :date
    add_column :rides, :date_and_time, :datetime
    rename_column :rides, :destination_type, :ride_type

    # === Addresses table changes ===
    add_column :addresses, :name, :string
    add_column :addresses, :phone, :string
    remove_column :addresses, :state, :string
    remove_column :addresses, :zip, :string
  end
end
