# frozen_string_literal: true

class Driver < ApplicationRecord
  validates :name, :phone, presence: true
  validates :email, :active, presence: false
  # validates :phone, format: { with: /\A\(\d{3}\)\d{3}-\d{3}\z/, message: "must be in format (xxx)xxx-xxx" }
  has_many :shifts, dependent: :destroy
end
