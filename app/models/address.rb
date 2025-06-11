# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :passengers

  # enforce uniqueness to prevent dupliciate addresses. This is model level validation
  # but it is not the only enforcement, just one of many
  validates :street, :city, presence: true
  validates :street, uniqueness: { scope: [:city, :zip_code] }

  def full_address
    name_part = name.present? ? "(#{name}) " : ""
    "#{name_part}#{street}, #{city}, #{zip_code}"
  end

  private
  def normalize_fields
    self.street = street.to_s.strip.titleize
    self.city = city.to_s.strip.titleize
    self.zip_code = zip_code.to_s.strip
  end
end
