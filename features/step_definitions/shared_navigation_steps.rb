# frozen_string_literal: true

# Given("I am on the {string} page") do |page_title|
#   title_to_path = {
#     "Home" => root_path,
#     "Today's Rides" => today_rides_path,
#     "Read-Only Shift Calendar" => read_only_shifts_path,
#     "Shifts Calendar" => shifts_path,
#     "New Shift" => new_shift_path,
#   }

# end





Then("I should see {string} button") do |button_text|
  found = page.has_button?(button_text) || page.has_link?(button_text)
  expect(found).to be true
end
