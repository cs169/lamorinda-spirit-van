# frozen_string_literal: true

class Passenger < ApplicationRecord
  # since passenger has the associated address_id, it should have the belongs_to
  belongs_to :address
  # for new address record whne creating new passenger
  accepts_nested_attributes_for :address
  has_many :rides, dependent: :nullify
  delegate :full_address, to: :address, allow_nil: true

  # Override the default nested-attributes setter to "find or create" the Address.
  def address_attributes=(attrs)
    # Use default rails handler for nested-attributes if blank
    return super if attrs.values.all?(&:blank?)

    normalized = {}
    normalized[:street] = attrs[:street].to_s.strip.titleize if attrs[:street].present?
    normalized[:city]   = attrs[:city].to_s.strip.titleize   if attrs[:city].present?
    normalized[:state]  = attrs[:state].to_s.strip.upcase    if attrs[:state].present?
    normalized[:zip_code] = attrs[:zip_code].to_s.strip      if attrs[:zip_code].present?

    existing = Address.find_by(normalized)
    if existing
      self.address = existing
    else
      super(normalized)
    end
  end

  def hispanic?
    self.hispanic == "true"
  end
end
