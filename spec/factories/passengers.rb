# frozen_string_literal: true

FactoryBot.define do
  factory :passenger do
    name { Faker::Name.unique.name }
    association :address
    phone { Faker::PhoneNumber.unique.phone_number }
    alternative_phone { Faker::PhoneNumber.unique.phone_number }
    email { Faker::Internet.unique.email }
    birthday { Faker::Date.birthday(min_age: 50, max_age: 110) }
    date_registered { Faker::Time.between(from: 365.days.ago, to: Time.now) }
    race { rand(1..5) }
    hispanic { rand(0..1) }
    wheelchair { [true, false].sample }
    low_income { [true, false].sample }
    disabled { [true, false].sample }
    need_caregiver { [true, false].sample }
    lmv_member { [true, false].sample }
    notes { Faker::Lorem.sentence }
    audit { Faker::Lorem.sentence }
    mail_updates { Faker::Lorem.sentence }
    rqsted_newsletter { ["Yes", "No"].sample }
  end
end
