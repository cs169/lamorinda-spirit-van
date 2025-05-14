# frozen_string_literal: true

class Driver < ApplicationRecord
  has_many :shifts, dependent: :destroy
  has_many :rides, through: :shifts
end
