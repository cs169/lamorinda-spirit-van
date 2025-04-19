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
