class AddNameToAddressUniquenessIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :addresses, name: "index_addresses_on_full_address", if_exists: true
    add_index :addresses, [:street, :city, :zip_code, :name], unique: true, name: "index_addresses_on_full_location"
  end
end
