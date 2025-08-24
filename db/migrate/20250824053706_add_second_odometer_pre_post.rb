class AddSecondOdometerPrePost < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :second_odometer_pre, :string
    add_column :shifts, :second_odometer_post, :string
  end
end
