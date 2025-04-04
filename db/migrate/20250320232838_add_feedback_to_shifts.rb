class AddFeedbackToShifts < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :van, :integer
    add_column :shifts, :pick_up_time, :string
    add_column :shifts, :drop_off_time, :string
    add_column :shifts, :odometer_pre, :string
    add_column :shifts, :odometer_post, :string
  end
end
