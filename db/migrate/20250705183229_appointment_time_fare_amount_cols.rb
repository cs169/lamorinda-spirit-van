class AppointmentTimeFareAmountCols < ActiveRecord::Migration[7.2]
  def change
    add_column :rides, :appointment_time, :time
    add_column :rides, :fare_amount, :decimal, precision: 10, scale: 2
  end
end
