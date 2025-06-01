class AddNextRideToRides < ActiveRecord::Migration[7.2]
  def change
    add_reference :rides, :next_ride, foreign_key: { to_table: :rides }
  end
end
