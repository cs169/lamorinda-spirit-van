class AddRideToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_reference :feedbacks, :ride, null: false, foreign_key: true
  end
end
