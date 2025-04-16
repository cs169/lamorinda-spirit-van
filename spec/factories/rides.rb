# frozen_string_literal: true

FactoryBot.define do
  factory :ride do
    date { Time.zone.today }
    association :driver
    van { 1 }
    association :passenger
    association :start_address, factory: :address
    association :dest_address, factory: :address
    address_name { "Default Address Name" }
    destination_type { "Default Type" }
    notes_about_location { "Default Note About Location" }
    wheelchair { false }
    new_passenger { false }
    low_income { false }
    disabled { false }
    need_caregiver { false }
    notes { "Default Note" }
    hours { 1.0 }
    amount_paid { 0 }
    confirmed_with_passenger { "No" }
    emailed_driver { nil }
  end
end
