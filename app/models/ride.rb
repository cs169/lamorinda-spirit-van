# frozen_string_literal: true

class Ride < ApplicationRecord
  has_one :feedback
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
    puts "START ADDRESS ATTRS RECEIVED: #{attrs.inspect}"
    normalized = normalize_address(attrs)
    puts "NORMALIZED: #{normalized}"
    existing_address = Address.find_by(normalized)
    puts "address size : #{Address.count}"

    if existing_address
      puts "✅ Found existing start_address: #{existing_address.id}"
      self.start_address = existing_address
    else
      puts "🚨 Creating new address with: #{normalized}"
      self.build_start_address(normalized)
    end
  end

  def dest_address_attributes=(attrs)
    normalized = normalize_address(attrs)
    puts "🔍 Attempting to find address with: #{normalized.inspect}"
    existing_address = Address.find_by(normalized)

    if existing_address
      puts "✅ Found existing existing_address: #{existing_address.id}"
      self.dest_address = existing_address
    else
      puts "🚨 Creating new address with: #{normalized}"
      self.build_dest_address(normalized)
    end
  end

  def self.build_linked_rides(ride_attrs, addrs)
    prev_ride = nil
    created_rides = []

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

    # change: stringified addresses, don't think this affects anything but remove 
  private
  def normalize_address(attrs)
    {
      "street" => attrs[:street].to_s.strip.titleize,
      "city"   => attrs[:city].to_s.strip.titleize,
      "state"  => attrs[:state].to_s.strip.upcase,
      "zip"    => attrs[:zip].to_s.strip
    }
  end
end
