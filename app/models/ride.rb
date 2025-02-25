class Ride < ApplicationRecord
  validates :day, :date, :passenger_name_and_phone, presence: true
end
