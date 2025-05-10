class CreateShiftTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :shift_templates do |t|
      t.string :shift_type
      t.integer :day_of_week
      t.references :driver, null: false, foreign_key: true

      t.timestamps
    end
  end
end
