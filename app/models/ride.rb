class Ride < ApplicationRecord
  validates :day, :date, :passenger_name_and_phone, presence: true

  scope :today, -> { where(date: Date.today) }

  scope :filter_by_driver, ->(driver_name) {
    where("driver LIKE ?", "%#{driver_name}%") if driver_name.present?
  }

  def self.filtered_rides(driver_name)
    today.filter_by_driver(driver_name)
  end
end
