class AddNotesToShift < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :notes, :text
  end
end
