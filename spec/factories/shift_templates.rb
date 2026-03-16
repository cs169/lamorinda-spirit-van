# frozen_string_literal: true

FactoryBot.define do
  factory :shift_template do
    day_of_week { rand(0..6) }
    shift_type { ["am", "pm", "Shopping", "CC", "LMV"].sample }
    transient { driver_name { nil } }
    driver { if driver_name then association(:driver, name: driver_name) else association(:driver) end }
  end
end
