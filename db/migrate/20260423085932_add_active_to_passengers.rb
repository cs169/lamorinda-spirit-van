class AddActiveToPassengers < ActiveRecord::Migration[7.2]
  def change
    add_column :passengers, :active, :boolean, default: true, null: false
  end
end
