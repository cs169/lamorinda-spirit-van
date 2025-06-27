# frozen_string_literal: true


# Scenario: Dispatcher creates a new shift from calendar
Then("I should see each day has a button for create a new shift") do
  day_cells = all("td")
  shift_buttons = day_cells.select { |td| td.has_link?("New shift") }
  expect(shift_buttons.count).to be > 0
end

When("I click one day's {string} button") do |button_text|
  # Match any tag that has the correct text and a data-date attribute
  expect(page).to have_selector("*[data-date]", text: button_text)

  # Find all elements with that text and data-date, regardless of tag
  buttons = all("*[data-date]", text: button_text)

  raise "No '#{button_text}' button with data-date found" if buttons.empty?

  selected = buttons.sample
  @clicked_date = Date.parse(selected[:'data-date'])
  selected.click
end

Then("the shift date field should show the date of the day I selected") do
  input_value = find("#shift_shift_date").value
  expect(input_value).to eq @clicked_date.to_s
end


# Scenario: Dispatcher clicks on driver name to view their upcoming shifts
When("I click on a driver's name") do
  driver_link = find(".driver-link", match: :first)
  @clicked_driver_name = driver_link.text
  driver_link.click
end

Then("I should see a list of upcoming shifts belonging to that driver") do
  expect(page).to have_content(@clicked_driver_name)
  if page.has_css?(".list-group-item")
    page.all('.list-group-item').each do |item|
      expect(item).to have_content("Shift Date:")
      expect(item.text).to match(/\w+day, \w{3} \d{2}, \d{4}/)
    end
  else
    expect(page).to have_content("No upcoming shifts assigned this month for this driver")
  end
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
