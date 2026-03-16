# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    street { Faker::Address.street_address }
    city   { Faker::Address.city }
    zip_code { Faker::Address.zip_code }
    name   { Faker::Address.community }
    phone  { Faker::PhoneNumber.unique.phone_number }

    # Custom trait for the Lamorinda region
    trait :lamorinda do
      transient do
        location do
          [
            { city: "Lafayette", zip: "94549" },
            { city: "Moraga",    zip: "94556" },
            { city: "Orinda",    zip: "94563" }
          ].sample
        end
      end
      city     { location[:city] }
      zip_code { location[:zip] }
    end
  end
end
