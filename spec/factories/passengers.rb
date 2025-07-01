# frozen_string_literal: true

FactoryBot.define do
  factory :passenger do
    sequence(:name) { |n| "#{n.humanize.titleize}y Mc#{n.humanize.titleize}son" }
    association :address
    sequence(:phone)  { |n| "(#{n}#{n}#{n})-#{n}#{n}#{n}-#{n}#{n}#{n}#{n}" }
    birthday { Time.zone.now }
    race { 1 }
    hispanic { false }
    wheelchair { false }
    low_income { false }
    disabled { false }
    need_caregiver { false }
    sequence(:email)  { |n| "#{n.humanize}y_mc#{n.humanize}son@gmail.com" }
    date_registered { Time.zone.now }
  end
end
