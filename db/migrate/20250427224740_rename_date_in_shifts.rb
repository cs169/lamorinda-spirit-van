class RenameDateInShifts < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :date, :date
    remove_column :shifts, :shift_date, :date
  end
end
