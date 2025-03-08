class AddDriverToShifts < ActiveRecord::Migration[7.2]
  def change
    add_reference :shifts, :driver, null: false, foreign_key: true
  end
end
