# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :driver
  validates :shift_date, :shift_type, presence: true

  def self.shifts_by_date(shifts, shift_date)
    shifts.where(shift_date: shift_date)
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

  def self.fill_month(templates, month_date)
    current_shifts = shifts_for_month(month_date)

    Shift.transaction do
      (month_date.beginning_of_month..month_date.end_of_month).each do |date|
        templates.where(day_of_week: date.wday).each do |template|
          new_shift_attributes = { driver_id: template.driver_id, shift_type: template.shift_type, shift_date: date }

          unless current_shifts.exists?(new_shift_attributes)
            Shift.create! new_shift_attributes
          end
        end
      end
    end
  end

  private
  def self.shifts_for_month(month_date)
    Shift.where("shift_date >= ? AND shift_date <= ?", month_date.beginning_of_month, month_date.end_of_month)
  end
end
