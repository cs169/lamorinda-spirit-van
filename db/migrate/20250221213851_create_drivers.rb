class CreateDrivers < ActiveRecord::Migration[7.2]
  def change
    create_table :drivers do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.boolean :active

      t.timestamps
    end
  end
end
