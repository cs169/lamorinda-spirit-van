# frozen_string_literal: true

class ShiftTemplate < ApplicationRecord
  belongs_to :driver
  validates :day_of_week, :shift_type, presence: true
end
