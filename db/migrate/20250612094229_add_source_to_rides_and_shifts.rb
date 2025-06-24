class AddSourceToRidesAndShifts < ActiveRecord::Migration[7.2]
  def change
    add_column :rides, :source, :string
    add_column :shifts, :source, :string
    
    add_index :rides, :source
    add_index :shifts, :source
  end
end 