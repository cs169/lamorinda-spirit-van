class ChangeLmvMemberToBoolean < ActiveRecord::Migration[7.2]
  def up
    change_column :passengers, :lmv_member, :boolean, default: false
  end

  def down
    change_column :passengers, :lmv_member, :binary
  end
end
