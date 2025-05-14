# frozen_string_literal: true

FactoryBot.define do
    factory :ride do
      association :start_address, factory: :address
      association :dest_address, factory: :address
      association :passenger
      association :shift
      hours { 1.0 }
      amount_paid { 0 }
    end
  end
