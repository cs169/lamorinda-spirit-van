# frozen_string_literal: true

class Ride < ApplicationRecord
  has_one :feedback, dependent: :destroy
  belongs_to :passenger, optional: true
  belongs_to :driver
  belongs_to :start_address, class_name: "Address", foreign_key: :start_address_id
  belongs_to :dest_address, class_name: "Address", foreign_key: :dest_address_id
  belongs_to :next_ride, class_name: "Ride", optional: true
  has_one :previous_ride, class_name: "Ride", foreign_key: "next_ride_id", dependent: :destroy

  # this causes problems -- duplicated addresses
  # accepts_nested_attributes_for :start_address
  # accepts_nested_attributes_for :dest_address

  def start_address_attributes=(attrs)
    normalized = normalize_address(attrs)
    self.start_address = Address.find_or_create_by!(normalized)
  end

  def dest_address_attributes=(attrs)
    normalized = normalize_address(attrs)
    self.dest_address = Address.find_or_create_by!(normalized)
  end

  def self.build_linked_rides(ride_attrs, addrs)
    created_rides = []
    prev_ride = nil

    ActiveRecord::Base.transaction do
      i = 0
      while i < (addrs.length - 1)
        origin = addrs[i]
        destination = addrs[i + 1]

        ride = Ride.new(ride_attrs)
        ride.start_address_attributes = origin
        ride.dest_address_attributes = destination

        if prev_ride
          prev_ride.next_ride = ride
          prev_ride.save!
        end

        ride.save!
        created_rides << ride
        prev_ride = ride
        i += 1
      end
    end

    [created_rides, true]
  rescue => e
    [e, false]
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

  def self.extract_attrs_from_params(params)
    ride_attrs = params.except(:addresses_attributes).to_h
    addresses = params[:addresses_attributes]

    [:wheelchair, :low_income, :disabled, :need_caregiver].each do |field|
      ride_attrs[field] = (ride_attrs[field] == "Yes") if ride_attrs.key?(field)
    end

    [ride_attrs, addresses]
  end

  private
  def normalize_address(attrs)
    {
      name: attrs[:name].to_s.strip.presence,
      street: attrs[:street].to_s.strip.titleize,
      city: attrs[:city].to_s.strip.titleize,
      phone: attrs[:phone].to_s.strip.presence,
    }.compact
  end
end
