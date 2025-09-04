class AddSecondVanPupDoffFields < ActiveRecord::Migration[7.2]
  def change
    remove_column :shifts, :second_odometer_pre, :string
    remove_column :shifts, :second_odometer_post, :string
    add_column :shifts, :second_pick_up_time, :string
    add_column :shifts, :second_drop_off_time, :string
  end
end
