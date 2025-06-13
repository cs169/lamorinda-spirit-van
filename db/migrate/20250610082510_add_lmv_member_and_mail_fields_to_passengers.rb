class AddLmvMemberAndMailFieldsToPassengers < ActiveRecord::Migration[7.2]
  def change
    add_column :passengers, :lmv_member, :binary
    add_column :passengers, :mail_updates, :text
    add_column :passengers, :rqsted_newsletter, :string
  end
end 