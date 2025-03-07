class Driver < ApplicationRecord
    validates :name, :phone, :shifts, presence: true
    validates :email, :active, presence: false
  # validates :phone, format: { with: /\A\(\d{3}\)\d{3}-\d{3}\z/, message: "must be in format (xxx)xxx-xxx" }
end
