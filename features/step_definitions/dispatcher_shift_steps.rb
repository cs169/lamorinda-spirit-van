# frozen_string_literal: true


# Scenario: Dispatcher creates a new shift from calendar
Then("I should see each day has a button for create a new shift") do
  day_cells = all("td")
  shift_buttons = day_cells.select { |td| td.has_link?("New shift") }
  expect(shift_buttons.count).to be > 0
end

When("I click one day's {string} button") do |button_text|
  candidate_cells = all("td").select { |td| td.has_link?(button_text) }
  raise "No '#{button_text}' button found in any day cell" if candidate_cells.empty?

  target_cell = candidate_cells.sample
  clicked_date_str = target_cell.text.match(/\d{4}-\d{2}-\d{2}/)&.to_s
  unless clicked_date_str
    clicked_date_str = target_cell.find("a", text: button_text)[:href].match(/date=(\d{4}-\d{2}-\d{2})/)&.captures&.first
  end
  raise "Could not extract date from cell" unless clicked_date_str

  @clicked_date = Date.parse(clicked_date_str)
  target_cell.click_link(button_text)
end

Then("the shift date field should show the date of the day I selected") do
  input_value = find("#shift_date").value
  expect(input_value).to eq @clicked_date.to_s
end


# Scenario: Dispatcher clicks on driver name to view all their shifts
When("I click on a driver's name") do
  driver_link = find(".driver-link", match: :first)
  @clicked_driver_name = driver_link.text
  driver_link.click
end

Then("I should see a list of shifts belonging to that driver") do
  expect(page).to have_content(@clicked_driver_name)
  expect(page).to have_css("div.shift")
end


# Scenario: Dispatcher clicks on shift type to view shift details
When("I click on a shift type") do
  shift_type_link = find(".shift-type-link", match: :first)
  @clicked_shift_type = shift_type_link.text
  shift_type_link.click
end

Then("I should see the details of that shift") do
  expect(page).to have_content("Shift date")
  expect(page).to have_content("Driver name")
  expect(page).to have_content("Shift type")
end
