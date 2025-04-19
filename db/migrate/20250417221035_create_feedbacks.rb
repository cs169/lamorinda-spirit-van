class CreateFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :feedbacks do |t|
      t.string :companion
      t.string :mobility
      t.string :note
      t.string :pick_up_time
      t.string :drop_off_time
      t.decimal :fare, precision: 10, scale: 2

      t.timestamps
    end
  end
end
