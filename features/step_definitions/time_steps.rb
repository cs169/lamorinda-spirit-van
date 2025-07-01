# frozen_string_literal: true

When(/^the current date is (.*)$/) do |date|
  date = Time.zone.parse(date)
  travel_to Time.zone.local(date.year, date.month, date.day)
end

When(/^print current date$/) do
  puts Time.zone.today
end
