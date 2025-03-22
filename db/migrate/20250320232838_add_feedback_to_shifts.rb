class AddFeedbackToShifts < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :van, :integer
    add_column :shifts, :pu_time, :string
    add_column :shifts, :do_time, :string
    add_column :shifts, :odo_pre, :string
    add_column :shifts, :odo_pst, :string
  end
end
