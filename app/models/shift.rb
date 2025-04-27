# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :driver
  validates :date, :shift_type, presence: true

  def self.shifts_by_date(shifts, date)
    shifts.where(date: date)
  end

  def self.shifts_by_driver(shifts, driver_id)
    shifts = shifts.where(driver_id: driver_id) if driver_id.present?
    shifts
  end

  def self.today_driver_shifts(driver_id, date = nil)
    date = date.presence || Time.zone.today
    shifts = shifts_by_date(shifts_by_driver(Shift.all, driver_id), date)
    shifts.first
  end
end
