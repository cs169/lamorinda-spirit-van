class NewColumnsForRides < ActiveRecord::Migration[7.2]
  def change
    add_column :rides, :status, :string
    add_column :rides, :dispatcher_notes, :text
    remove_column :rides, :confirmed_with_passenger
    remove_column :rides, :emailed_driver
    rename_column :rides, :notes, :notes_to_driver
    rename_column :rides, :dispatcher_notes, :notes
  end
end
