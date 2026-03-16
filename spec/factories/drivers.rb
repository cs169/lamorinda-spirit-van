# frozen_string_literal: true

FactoryBot.define do
  factory :driver do
    name   { Faker::Name.unique.name }
    email  { Faker::Internet.unique.email }
    phone  { Faker::PhoneNumber.unique.phone_number }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
