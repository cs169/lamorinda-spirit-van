# frozen_string_literal: true

FactoryBot.define do
  factory :shift_template do
    day_of_week { 1 }
    shift_type { "am" }
    transient { driver_name { nil } }
    driver { if driver_name then association(:driver, name: driver_name) else association(:driver) end }
  end
end
