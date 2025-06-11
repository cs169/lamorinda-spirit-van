class AddZipCodeToAddresses < ActiveRecord::Migration[7.2]
  def change
    add_column :addresses, :zip_code, :string
  end
end
