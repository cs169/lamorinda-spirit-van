# frozen_string_literal: true

FactoryBot.define do
    factory :driver do
      sequence(:name) { |n| "Driver #{n.humanize.titleize}" }
      sequence(:email)  { |n| "driver_#{n.humanize}son@gmail.com" }
      sequence(:phone)  { |n| "(dri)-ver-#{n}#{n}#{n}#{n}" }
      active { true }
    end
  end
