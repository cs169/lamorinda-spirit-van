class UpdateRidesAndAddresses < ActiveRecord::Migration[7.2]
  def change
    # === Rides table changes ===
    remove_column :rides, :address_name, :string
    remove_column :rides, :notes_about_location, :text
    remove_column :rides, :date, :date
    remove_column :rides, :notes_date_reserved, :text
    add_column :rides, :date_and_time, :datetime
    rename_column :rides, :destination_type, :ride_type
    remove_column :rides, :emailed_driver, :string
    add_column :rides, :emailed_driver, :boolean


    # === Addresses table changes ===
    add_column :addresses, :name, :string
    add_column :addresses, :phone, :string
    remove_column :addresses, :state, :string
    remove_column :addresses, :zip, :string
  end
end
