class ReplaceLowIncomeWithFareType < ActiveRecord::Migration[7.2]
  def change
    remove_column :rides, :low_income
    add_column :rides, :fare_type, :text
  end
end
