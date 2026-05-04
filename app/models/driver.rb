# frozen_string_literal: true

class Driver < ApplicationRecord
  has_many :rides, dependent: :nullify
  has_many :shifts, dependent: :destroy
  scope :active, -> { where(active: true) }
end
