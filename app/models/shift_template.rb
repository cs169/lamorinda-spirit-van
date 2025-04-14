# frozen_string_literal: true

class ShiftTemplate < ApplicationRecord
  belongs_to :driver

  def to_date
    Date.today.beginning_of_week + day_of_week
  end

  def day_name
    Date::DAYNAMES[day_of_week]
  end
end
