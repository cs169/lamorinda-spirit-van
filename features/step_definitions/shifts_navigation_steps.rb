# frozen_string_literal: true

# Scenario: User navigates from "home" to "Today's Rides"
#     Given I am on the "home" page
#     When I click on "Today's Rides" button
#     Then I should be on the "Today's Rides" page

#   Scenario: User navigates from "Today's Rides" to "Read-Only Shift Calendar"
#     Given I am on the "Today's Rides" page
#     Then I should see "View Shifts" button
#     When I click on "View Shifts" button
#     Then I should be on the "Read-Only Shift Calendar" page

Given("I am on the {string} page") do |page_name|
  case page_name
  when "home"
    visit root_path
  when "Today's Rides"
    visit today_driver_path(id: 1)
  when "Read-Only Shift Calendar"
    visit read_only_shifts_path
  when "Shifts Calendar"
    visit shifts_path
  else
    raise "Unknown page name: #{page_name}"
  end
end

When("I click on {string} button") do |button_text|
  click_button(button_text) rescue click_link(button_text)
end

Then("I should be on the {string} page") do |page_name|
  case page_name
  when "Today's Rides"
    expect(current_path).to eq today_driver_path
  when "Read-Only Shift Calendar"
    expect(current_path).to eq read_only_shifts_path
  when "Shifts Calendar"
    expect(current_path).to eq shifts_path
  when "New Shift"
    new_shift_path(date: @clicked_date.to_s)
  else
    raise "Unknown page name: #{page_name}"
  end
end

Then("I should see {string} button") do |button_text|
  # search button or link
  found = page.has_button?(button_text) || page.has_link?(button_text)
  expect(found).to be true
end

Then("I should see the current month and year in the calendar title") do
  expected_title = Time.zone.today.strftime("%B %Y") # e.g., "March 2025"
  actual_title = find(".calendar-title").text
  expect(actual_title).to eq(expected_title)
end

Then("I should see {string} {string} {string} button") do |btn1, btn2, btn3|
  [btn1, btn2, btn3].each do |btn|
    found = page.has_button?(btn) || page.has_link?(btn)
    expect(found).to be true
  end
end

When("I note the current month title") do
  @current_month = find(".calendar-title").text
end

Then("I should see the month title change") do
  new_month = find(".calendar-title").text
  expect(new_month).not_to eq(@current_month)
end

Then("I should see the current month title again") do
  current_month = find(".calendar-title").text
  expect(current_month).to eq(@current_month)
end


Then("I should see each day has a button for create a new shift") do
  day_cells = all("td")
  shift_buttons = day_cells.select { |td| td.has_link?("New shift") }
  expect(shift_buttons.count).to be > 0
end


When("I click one day's {string} button") do |button_text|
  # Select all "New shift" table cells
  candidate_cells = all("td").select { |td| td.has_link?(button_text) }

  raise "No '#{button_text}' button found in any day cell" if candidate_cells.empty?

  # Choose one cell randomly
  target_cell = candidate_cells.sample

  # Extract the date from the cell
  clicked_date_str = target_cell.text.match(/\d{4}-\d{2}-\d{2}/)&.to_s
  unless clicked_date_str
    clicked_date_str = target_cell.find("a", text: button_text)[:href].match(/date=(\d{4}-\d{2}-\d{2})/)&.captures&.first
  end
  raise "Could not extract date from cell" unless clicked_date_str

  # Convert the date string to a Date object
  @clicked_date = Date.parse(clicked_date_str)

  # Click the button
  target_cell.click_link(button_text)
end

Then("the date should initially be the date of the corresponding table") do
  input_value = find("#shift_shift_date").value
  expect(input_value).to eq @clicked_date.to_s
end
