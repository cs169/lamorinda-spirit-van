# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    association :ride
    companion { "son" }
    mobility { "wheelchair" }
    note { "The passenger was late for 5 minutes" }
    pick_up_time { Time.zone.now }
    drop_off_time { Time.zone.now + 30.minutes }
    fare { 10.0 }
  end
end
