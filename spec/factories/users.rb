# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }

    trait :driver do
      role { "driver" }
    end

    trait :dispatcher do
      role { "dispatcher" }
    end

    trait :admin do
      role { "admin" }
    end
  end
end
