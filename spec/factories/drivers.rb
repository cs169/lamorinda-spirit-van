# frozen_string_literal: true

FactoryBot.define do
    factory :driver do
      sequence(:name) { |n| "Driver #{n.humanize.titleize}" }
      sequence(:email)  { |n| "driver#{n}@example.com" }
      sequence(:phone)  { |n| "(555) 123-#{n.to_s.rjust(4, '0')}" }
      active { true }
    end
  end
