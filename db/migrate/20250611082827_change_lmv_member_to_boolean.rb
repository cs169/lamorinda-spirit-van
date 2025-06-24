class ChangeLmvMemberToBoolean < ActiveRecord::Migration[7.2]
  def change
    remove_column :passengers, :lmv_member
    add_column :passengers, :lmv_member, :boolean
  end
end
