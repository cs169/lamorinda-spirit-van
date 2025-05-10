# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :passengers

  # enforce uniqueness to prevent dupliciate addresses. This is model level validation
  # but it is not the only enforcement, just one of many
  validates :street, :city, presence: true
  validates :street, uniqueness: { scope: [:city] }

  before_validation :normalize_fields

  def full_address
    [street, city].compact.join(", ")
  end

  private
  def normalize_fields
    self.street = street.strip.titleize
    self.city = city.strip.titleize
  end
end
