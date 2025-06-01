# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    name { "Kaiser" }
    sequence(:street) { |n| "#{n}#{n}#{n} #{n.ordinalize} Street" }
    city { "Lafayette" }
    phone { "(321)422-3211" }
  end
end
