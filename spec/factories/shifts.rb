# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    association :driver
    shift_date { Time.zone.now }
    shift_type { ["am", "pm", "Shopping", "CC", "LMV"].sample }
    van { rand(0..10) }
    odometer_pre { rand(10000..150000).to_s }

    after(:build) do |shift|
      shift.odometer_post ||= (shift.odometer_pre.to_i + rand(5..50)).to_s
    end
  end
end
