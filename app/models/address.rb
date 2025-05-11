# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :passengers

  # enforce uniqueness to prevent dupliciate addresses. This is model level validation
  # but it is not the only enforcement, just one of many
  validates :street, :city, presence: true
  validates :street, uniqueness: { scope: [:city] }

  before_validation :normalize_fields

  def full_address
    name_part = name.present? ? "(#{name}) " : ""
    "#{name_part}#{street}, #{city}"
  end

  private
  def normalize_fields
    self.street = street.strip.titleize
    self.city = city.strip.titleize
  end
end
