# frozen_string_literal: true

FactoryBot.define do
  factory :shift_template do
    day_of_week { 1 }
    shift_type { "am" }
    association :driver
  end
end
