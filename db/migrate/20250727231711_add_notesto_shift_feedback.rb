class AddNotestoShiftFeedback < ActiveRecord::Migration[7.2]
  def change
    add_column :shifts, :feedback_notes, :text
  end
end
