# frozen_string_literal: true

Given("I am on the {string} page") do |page_title|
  title_to_path = {
    "Home" => root_path,
    "Today's Rides" => today_rides_path,
    "Read-Only Shift Calendar" => read_only_shifts_path,
    "Shifts Calendar" => shifts_path,
    "New Shift" => new_shift_path,
  }

  path = title_to_path[page_title]
  raise "No known path for page title: '#{page_title}'" unless path

  visit path
end


When("I click on {string} button") do |button_text|
  click_button(button_text) rescue click_link(button_text)
end

Then("I should be on the {string} page") do |expected_title|
  actual_title = page.title
  expect(actual_title).to eq(expected_title)
end

Then("I should see {string} button") do |button_text|
  found = page.has_button?(button_text) || page.has_link?(button_text)
  expect(found).to be true
end
