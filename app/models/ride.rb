# frozen_string_literal: true

class Ride < ApplicationRecord
  has_one :feedback, dependent: :destroy
  belongs_to :passenger, optional: true
  belongs_to :driver
  belongs_to :start_address, class_name: "Address", foreign_key: :start_address_id
  belongs_to :dest_address, class_name: "Address", foreign_key: :dest_address_id
  belongs_to :next_ride, class_name: "Ride", optional: true
  has_one :previous_ride, class_name: "Ride", foreign_key: "next_ride_id"

  # this causes problems -- duplicated addresses
  # accepts_nested_attributes_for :start_address
  # accepts_nested_attributes_for :dest_address

  def emailed_driver?
    self.emailed_driver == "true"
  end

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

  private
  def normalize_address(attrs)
    {
      street: attrs[:street].to_s.strip.titleize,
      city: attrs[:city].to_s.strip.titleize,
      state: attrs[:state].to_s.strip.upcase,
      zip: attrs[:zip].to_s.strip
    }
  end
end
