# frozen_string_literal: true

FactoryBot.define do
  factory :ride do
    date { Date.current }
    appointment_time { Time.current }
    association :driver
    van { 1 }
    association :passenger
    association :start_address, factory: :address
    association :dest_address, factory: :address
    ride_type { "Default Type" }
    fare_type { "Default Type" }
    wheelchair { false }
    disabled { false }
    need_caregiver { false }
    notes_to_driver { "Default Note" }
    hours { 1.0 }
    amount_paid { 0 }
    fare_amount { 10 }
  end
end
