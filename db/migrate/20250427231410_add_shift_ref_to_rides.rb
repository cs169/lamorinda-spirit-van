class AddShiftRefToRides < ActiveRecord::Migration[7.2]
  def change
    remove_column :rides, :date, :date
    remove_column :rides, :van, :integer
    remove_reference :rides, :driver, index: true
    remove_column :rides, :emailed_driver, :binary
    add_reference :rides, :shift, foreign_key: true

    remove_column :shifts, :emailed_driver, :binary
  end
end
