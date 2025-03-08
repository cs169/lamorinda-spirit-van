class CreateShifts < ActiveRecord::Migration[7.2]
  def change
    create_table :shifts do |t|
      t.date :shift_date
      t.string :shift_type

      t.timestamps
    end
  end
end
