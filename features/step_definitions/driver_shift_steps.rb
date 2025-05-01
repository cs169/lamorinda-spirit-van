# frozen_string_literal: true

Then("I should see the rides for one day ago") do
  expected_date = (Time.zone.today - 1.day).strftime("%m/%d/%Y")
  expect(page).to have_content(expected_date)
end

Then("I should see the rides for two days ago") do
  expected_date = (Time.zone.today - 2.days).strftime("%m/%d/%Y")
  expect(page).to have_content(expected_date)
end

Then("I should see the rides for today") do
  expected_date = Time.zone.today.strftime("%m/%d/%Y")
  expect(page).to have_content(expected_date)
end

When("I remember the current rides page URL") do
  @rides_page_url = current_url
end

Then("I should return to the remembered rides page URL") do
  expect(current_url).to eq(@rides_page_url)
end

Given(/^I visit the Today's Rides page for that driver$/) do
  driver_id = @driver_id || @driver&.id
  raise "No driver id defined for today's rides page" unless driver_id

  visit today_driver_path(driver_id)
end

# Scenario: Viewing the current month in the shift calendar
Then("I should see the current month and year in the calendar title") do
  expected_title = Time.zone.today.strftime("%B %Y")
  actual_title = find(".calendar-title").text
  expect(actual_title).to eq(expected_title)
end

# Scenario: Driver can switch month
Then("I should see the {string}, {string}, and {string} buttons") do |btn1, btn2, btn3|
  [btn1, btn2, btn3].each do |btn|
    found = page.has_button?(btn) || page.has_link?(btn)
    expect(found).to be true
  end
end

Then("I should see the current month title") do
  expected_title = Time.zone.today.strftime("%B %Y")
  actual_title = find(".calendar-title").text
  expect(actual_title).to eq(expected_title)
end

Then("I should see the previous month title") do
  expected_title = (Time.zone.today - 1.month).strftime("%B %Y")
  actual_title = find(".calendar-title").text
  expect(actual_title).to eq(expected_title)
end

Then("I should see the next month title") do
  expected_title = (Time.zone.today + 1.month).strftime("%B %Y")
  actual_title = find(".calendar-title").text
  expect(actual_title).to eq(expected_title)
end
