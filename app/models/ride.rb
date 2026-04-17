# frozen_string_literal: true

class Ride < ApplicationRecord
  has_one :feedback, dependent: :destroy
  belongs_to :passenger, optional: true
  belongs_to :driver
  belongs_to :start_address, class_name: "Address", foreign_key: :start_address_id
  belongs_to :dest_address, class_name: "Address", foreign_key: :dest_address_id
  belongs_to :next_ride, class_name: "Ride", optional: true
  has_one :previous_ride, class_name: "Ride", foreign_key: "next_ride_id", dependent: :destroy

  after_create :create_initial_feedback

  # this causes problems -- duplicated addresses  <--  Not Anymore ^^
  # accepts_nested_attributes_for :start_address
  # accepts_nested_attributes_for :dest_address

  def start_address_attributes=(attrs)
    self.start_address = get_or_generate_address(attrs)
  end

  def dest_address_attributes=(attrs)
    self.dest_address = get_or_generate_address(attrs)
  end

  def self.build_linked_rides!(ride_attrs, addrs, stops_data = [])
    created_rides = []
    prev_ride = nil

    addrs&.each_cons(2)&.with_index do |(origin, destination), i|
      # Create ride with base attributes
      ride = Ride.new(ride_attrs)

      # These setters use find_or_create_by! and would raise ActiveRecord::RecordInvalid if necessary
      ride.start_address_attributes = origin
      ride.dest_address_attributes = destination

      # Override driver and van if provided in stops_data
      if stops_data&.[](i)
        stop_data = stops_data[i]
        ride.driver_id = stop_data[:driver_id] if stop_data[:driver_id].present?
        ride.van = stop_data[:van] if stop_data[:van].present?
      end

      if prev_ride
        prev_ride.next_ride = ride
      end

      ride.validate!
      created_rides << ride
      prev_ride = ride
    end

    if created_rides.empty?
      raise ActiveRecord::RecordInvalid.new(Ride.new)
    end

    created_rides
  end

  def get_all_linked_rides
    chain = [self]
    current = self
    while current.next_ride
      chain << current.next_ride
      current = current.next_ride
    end
    chain
  end

  def walk_to_root
    ride = self
    ride = ride.previous_ride while ride.previous_ride
    ride
  end

  def all_drivers_names
    get_all_linked_rides.map { |ride| (ride.driver&.name || "Unknown") }.uniq.join(", ")
  end

  def all_vans_numbers
    get_all_linked_rides.filter_map { |ride| ride.van }.uniq.join(", ")
  end

  def self.extract_attrs_from_params(params)
    ride_attrs = params.except(:addresses_attributes, :stops_attributes).to_h
    addresses = params[:addresses_attributes]
    stops_data = params[:stops_attributes] || []

    [:wheelchair, :disabled, :need_caregiver].each do |field|
      ride_attrs[field] = (ride_attrs[field] == "Yes") if ride_attrs.key?(field)
    end

    [ride_attrs, addresses, stops_data]
  end

  private
  def create_initial_feedback
    self.create_feedback!
  end

  def normalize_address(attrs)
    {
      name: attrs[:name].to_s.strip.presence,
      street: attrs[:street].to_s.strip.titleize,
      city: attrs[:city].to_s.strip.titleize,
    }
  end

  def get_or_generate_address(attrs)
    normalized = normalize_address(attrs)
    addr = Address.find_or_create_by!(normalized)
    addr.update(phone: attrs[:phone].to_s.strip.presence) if attrs[:phone].present?

    addr
  end
end
