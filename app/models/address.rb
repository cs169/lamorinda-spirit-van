# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :passengers

  # enforce uniqueness to prevent dupliciate addresses. This is model level validation
  # but it is not the only enforcement, just one of many
  validates :street, :city, presence: true
  validates :street, uniqueness: { scope: [:city, :zip_code] }

  def full_address
    name_part = name.present? ? "(#{name}) " : ""
    zip_part = zip_code? ? ", (#{zip_code})" : ""
    "#{name_part}#{street}, #{city}#{zip_part}"
  end

end
