# Given("I am on the passengers page") do
#   visit passengers_path
#   expect(page).to have_css("table")
# end

Given("I am on the passengers page sorted by {string} in {string} order") do |column, direction|
  visit passengers_path(sort: column.downcase, direction: direction.downcase)
  expect(page).to have_css("table")
end

When("I fill in the search field with {string}") do |query|
  fill_in(nil, with: query, id: "dt-search-0")
  sleep 1
end

When("I press {string}") do |button|
  click_button button
end

Then("I should see {string} in the table") do |text|
  expect(page).to have_css("table", text: text)
end

Then("I should not see {string} in the table") do |text|
  expect(page).not_to have_css("table", text: text)
end

Then("the first row in the table should have {string} in the {string} column") do |expected_text, column_name|
  headers = all("table thead th").map(&:text)
  column_index = headers.index(column_name)
  expect(column_index).not_to be_nil, "Column '#{column_name}' not found in table header"
  
  first_row = find("table tbody tr", match: :first)
  cells = first_row.all("td")
  
  expect(cells[column_index]).to have_text(expected_text)
end
