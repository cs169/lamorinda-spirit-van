# frozen_string_literal: true

class Ride < ApplicationRecord
  belongs_to :passenger, optional: true
  belongs_to :driver
  belongs_to :start_address, class_name: "Address", foreign_key: :start_address_id
  belongs_to :dest_address, class_name: "Address", foreign_key: :dest_address_id

  accepts_nested_attributes_for :start_address
  accepts_nested_attributes_for :dest_address

  def emailed_driver?
    self.emailed_driver == "true"
  end

  def self.rides_by_date(rides, date)
    rides.where(date: date)
  end

  def self.rides_by_driver(rides, driver_id)
    rides = rides.where(driver_id: driver_id) if driver_id.present?
    rides
  end

  def self.driver_today_view(date = nil)
    date = date.presence || Time.zone.today
    rides = rides_by_date(Ride.all, date)
    rides
  end

  def self.today_driver_view(driver_id, date = nil)
    date = date.presence || Time.zone.today
    rides = rides_by_date(rides_by_driver(Ride.all, driver_id), date)
    rides
  end

  # # Filtering logic for rides table
  # def self.filter_rides(filter_params)
  #   rides = Ride.all

  #   # Handle LIKE filters in a loop
  #   {
  #     day: "day",
  #     driver_name: "driver",
  #     passenger_name_and_phone: "passenger_name_and_phone",
  #     passenger_address: "passenger_address",
  #     destination: "destination",
  #     driver_email: "driver_email",
  #     driver_initials: "driver_initials",
  #     confirmed: "confirmed_with_passenger"
  #   }.each do |key, column|
  #     if filter_params[key].present?
  #       rides = rides.where(Ride.arel_table[column].lower.matches("%#{filter_params[key].downcase}%"))
  #     end
  #   end

  #   # Handle exact match filters
  #   {
  #     ride_count: "ride_count",
  #     amount_paid: "amount_paid",
  #     hours: "hours"
  #   }.each do |key, column|
  #     rides = rides.where(column => filter_params[key]) if filter_params[key].present?
  #   end

  #   # Handle date range filters
  #   if filter_params[:start_date].present?
  #     rides = rides.where("date >= ?", Date.parse(filter_params[:start_date]))
  #   end

  #   date_end = filter_params[:end_date].present? ? Date.parse(filter_params[:end_date]) : Date.today
  #   rides = rides.where("date <= ?", date_end) if date_end

  #   # Handle simple presence filter
  #   rides = rides.where(van: filter_params[:van]) if filter_params[:van].present?

  #   rides
  # end
  def start_address_attributes=(attrs)
    normalized = normalize_address(attrs)
    existing_address = Address.find_by(normalized)

    if existing_address
      self.start_address = existing_address
    else
      self.build_start_address(normalized)
    end
  end

  def dest_address_attributes=(attrs)
    normalized = normalize_address(attrs)
    existing_address = Address.find_by(normalized)

    if existing_address
      self.dest_address = existing_address
    else
      self.build_dest_address(normalized)
    end
  end

  private
  def normalize_address(attrs)
    {
      street: attrs[:street].to_s.strip.titleize,
      city:   attrs[:city].to_s.strip.titleize,
      state:  attrs[:state].to_s.strip.upcase,
      zip:    attrs[:zip].to_s.strip
    }
  end
end
