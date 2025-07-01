# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    shift_date { Time.zone.now }
    shift_type { "am" }
    association :driver
  end
end
