Given("I am on the passengers page") do
  visit passengers_path
  # Optionally check that the table is rendered
  expect(page).to have_css("table")
end

# This step simulates visiting the page with sort parameters.
Given("I am on the passengers page sorted by {string} in {string} order") do |column, direction|
  # Adjust the query string to match your server-side implementation.
  visit passengers_path(sort: column.downcase, direction: direction.downcase)
  expect(page).to have_css("table")
end

# Standard Capybara steps for filling in a form field.
When("I fill in the search field with {string}") do |query|
  # fill_in field, with: value
  fill_in(nil, with: query, id: "dt-search-0")
  # Optional: wait a moment for the DataTable to update its filtering.
  sleep 1
end

# Standard Capybara step to click a button.
When("I press {string}") do |button|
  click_button button
end

# Verifies that the given text appears somewhere in the table.
Then("I should see {string} in the table") do |text|
  expect(page).to have_css("table", text: text)
end

# Verifies that the given text does not appear in the table.
Then("I should not see {string} in the table") do |text|
  expect(page).not_to have_css("table", text: text)
end

# Checks that the first row contains the expected text in the specified column.
Then("the first row in the table should have {string} in the {string} column") do |expected_text, column_name|
  # Find the table headers and compute the column index for the specified column.
  headers = all("table thead th").map(&:text)
  column_index = headers.index(column_name)
  expect(column_index).not_to be_nil, "Column '#{column_name}' not found in table header"
  
  # Get the first row of the table body.
  first_row = find("table tbody tr", match: :first)
  cells = first_row.all("td")
  
  # Ensure the cell at the computed column index contains the expected text.
  expect(cells[column_index]).to have_text(expected_text)
end
