class UpdateAddressesIndex < ActiveRecord::Migration[7.0]
  def change
    # Add the new index that includes street, city, and zip_code
    add_index :addresses, [:street, :city, :zip_code], unique: true, name: "index_addresses_on_full_address"
  end
end
