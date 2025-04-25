# frozen_string_literal: true

class Ride < ApplicationRecord
  belongs_to :passenger, optional: true
  belongs_to :driver
  belongs_to :start_address, class_name: "Address", foreign_key: :start_address_id
  belongs_to :dest_address, class_name: "Address", foreign_key: :dest_address_id
  belongs_to :next_ride, class_name: "Ride", optional: true
  has_one :previous_ride, class_name: "Ride", foreign_key: "next_ride_id"

  accepts_nested_attributes_for :start_address
  accepts_nested_attributes_for :dest_address

  def emailed_driver?
    self.emailed_driver == "true"
  end

  def start_address_attributes=(attrs)
    puts "START ADDRESS ATTRS RECEIVED: #{attrs.inspect}"
    normalized = normalize_address(attrs)
    puts "NORMALIZED: #{normalized}"
    existing_address = Address.find_by(normalized)

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
    i = 0
   
    while i < (addrs.length - 1)
      origin = addrs[i]
      destination = addrs[i + 1]

      # new_params = ride_attrs.merge(
      #   start_address_attributes: origin,
      #   dest_address_attributes: destination
      # )

      ride = Ride.new(ride_attrs)
      ride.start_address_attributes = origin
      ride.dest_address_attributes = destination

      if prev_ride
        prev_ride.next_ride = ride
      end

      created_rides << ride
      prev_ride = ride
      i += 1
    end

    created_rides
  end

  def self.save_rides(created_rides)
    created_rides.each do |ride|
      puts "Ride ##{ride.inspect} failed with errors: #{ride.errors.full_messages.join(', ')}"
      return [false, ride] unless ride.save
    end
    [true, nil]
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
