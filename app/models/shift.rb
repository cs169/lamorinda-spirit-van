# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :driver
  validates :shift_date, :shift_type, presence: true
  validates :odometer_pre, :odometer_post,
            numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validate :odometer_post_not_less_than_pre

  SHIFT_TYPES = %w[AM PM Volunteer CC].freeze

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

    batch = []
    (month_date.beginning_of_month.to_date..month_date.end_of_month.to_date).each do |date|
      templates.where(day_of_week: date.wday).each do |template|
        new_shift_attributes = { driver_id: template.driver_id, shift_type: template.shift_type, shift_date: date }

        unless current_shifts.exists?(new_shift_attributes)
          batch.push Shift.new(new_shift_attributes)
        end
      end
    end

    Shift.transaction { batch.each(&:save) }

    batch.map { |shift| shift.errors.full_messages }.flatten
  end

  def self.clear_month(month_date)
    Shift.destroy shifts_for_month(month_date).map(&:id)
  end

  private
  def self.shifts_for_month(month_date)
    Shift.where("shift_date >= ? AND shift_date <= ?", month_date.beginning_of_month, month_date.end_of_month)
  end

  def odometer_post_not_less_than_pre
    return if odometer_pre.blank? || odometer_post.blank?

    pre  = Float(odometer_pre,  exception: false)
    post = Float(odometer_post, exception: false)
    return if pre.nil? || post.nil?

    if post < pre
      errors.add(:odometer_post, "must be greater than or equal to the pre-trip odometer reading")
    end
  end
end
