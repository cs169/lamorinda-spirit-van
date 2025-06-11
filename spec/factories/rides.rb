# frozen_string_literal: true

FactoryBot.define do
  factory :ride do
    date_and_time { Time.zone.now.change(min: 0, sec: 0) }
    association :driver
    van { 1 }
    association :passenger
    association :start_address, factory: :address
    association :dest_address, factory: :address
    ride_type { "Default Type" }
    wheelchair { false }
    low_income { false }
    disabled { false }
    need_caregiver { false }
    notes_to_driver { "Default Note" }
    hours { 1.0 }
    amount_paid { 0 }
  end
end
