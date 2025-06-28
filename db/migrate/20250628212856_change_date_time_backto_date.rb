class ChangeDateTimeBacktoDate < ActiveRecord::Migration[7.2]
  def up
    change_column :rides, :date_and_time, :date
    rename_column :rides, :date_and_time, :date
  end

  def down
    rename_column :rides, :date, :date_and_time
    change_column :rides, :date_and_time, :datetime
  end
end
