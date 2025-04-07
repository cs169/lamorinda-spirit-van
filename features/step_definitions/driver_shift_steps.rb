# frozen_string_literal: true

Given("I am on Today's Rides page for that driver") do
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
