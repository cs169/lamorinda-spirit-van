# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    association :ride
    companion { Faker::Name.unique.name }
    mobility { ["Independent", "Needs assistance", "Wheelchair user"].sample }
    note { Faker::Lorem.sentence }
    pick_up_time { Time.zone.now }
    drop_off_time { Time.zone.now + 30.minutes }
    fare { rand(5.0..50.0).round(2) }
  end
end
