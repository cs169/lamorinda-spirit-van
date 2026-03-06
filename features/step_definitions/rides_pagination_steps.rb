# frozen_string_literal: true

Given(/^(\d+) rides exist$/) do |count|
  driver    = FactoryBot.create(:driver)
  passenger = FactoryBot.create(:passenger)
  count.to_i.times do |i|
    FactoryBot.create(:ride, driver: driver, passenger: passenger, date: i.days.ago)
  end
end

When(/^I visit the rides index page$/) do
  visit rides_path
end

Then(/^I should see (\d+) rides? in the table$/) do |count|
  expect(page).to have_css("tbody tr", count: count.to_i)
end

Then(/^I should see pagination controls$/) do
  expect(page).to have_css("nav.pagy-bootstrap")
end

When(/^I click on page "([^"]*)" in the pagination$/) do |page_num|
  within(first("nav.pagy-bootstrap")) do
    click_link page_num
  end
end
