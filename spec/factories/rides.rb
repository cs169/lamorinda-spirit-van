# frozen_string_literal: true

FactoryBot.define do
  factory :ride do
    date { Date.current }
    appointment_time { Time.current }
    hours { rand(0.5..3.0).round(2) }
    fare_amount { rand(5.0..50.0).round(2) }
    amount_paid { rand(5.0..50.0).round(2) }
    van { rand(0..10) }
    ride_type { ["One-way", "Round-trip"].sample }
    fare_type { ["R", "LMV", "CC", "Shopping"].sample }
    status { ["Scheduled", "Requested", "Waitlisted", "Email sent", "Cancelled", "Confirmed", "Pending"].sample }
    source { ["Phone", "Email"].sample }
    wheelchair { [true, false].sample }
    disabled { [true, false].sample }
    need_caregiver { [true, false].sample }
    notes_to_driver { Faker::Lorem.sentence }
    notes { Faker::Lorem.sentence }
    association :driver
    association :passenger
    association :start_address, factory: :address
    association :dest_address, factory: :address
  end
end
