# frozen_string_literal: true

class Feedback < ApplicationRecord
  belongs_to :ride

  MOBILITY_OPTIONS = [ "Walker", "Cane", "Wheelchair", "None", "Other" ].freeze
end
