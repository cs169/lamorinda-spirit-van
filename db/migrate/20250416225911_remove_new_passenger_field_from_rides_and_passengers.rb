class RemoveNewPassengerFieldFromRidesAndPassengers < ActiveRecord::Migration[7.2]
  def change
    remove_column :rides, :new_passenger, :boolean
    remove_column :passengers, :new_passenger, :boolean
  end
end
