# frozen_string_literal: true

class Address < ApplicationRecord
  has_many :passengers

  before_validation :nilify_fields

  # enforce uniqueness to prevent duplicate addresses. This is model level validation
  # but it is not the only enforcement, just one of many
  validates :street, :city, presence: true
  validates :street, uniqueness: { scope: [:city, :zip_code, :name] }

  def full_address
    name_part = name.present? ? "(#{name}) " : ""
    zip_part = zip_code? ? ", (#{zip_code})" : ""
    "#{name_part}#{street}, #{city}#{zip_part}"
  end

  def address_no_zip
    name_part = name.present? ? "(#{name}) " : ""
    "#{name_part}#{street}, #{city}"
  end


  private
  def nilify_fields
    self.name = name.presence   # Turns "" or "  " into nil
  end
end
