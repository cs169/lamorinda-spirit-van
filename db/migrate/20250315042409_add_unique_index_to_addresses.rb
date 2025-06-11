class AddUniqueIndexToAddresses < ActiveRecord::Migration[7.2]
  def change
    remove_index :addresses, name: 'index_addresses_on_full_address'
    
    add_index :addresses, [:street, :city, :zip_code], unique: true, name: 'index_addresses_on_full_address'
  end
end
