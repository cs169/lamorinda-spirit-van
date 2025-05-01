# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    date { DateTime.now }
    shift_type { "am" }
    emailed_driver { false }
    association :driver
  end
end
