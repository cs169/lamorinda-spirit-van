# frozen_string_literal: true

Given("I am on the {string} page") do |page_title|
  title_to_path = {
    "Log in" => new_user_session_path,
    "Sign up" => new_user_registration_path,
    "Home" => root_path,
    "Lamorinda" => root_path,
    "Shifts" => read_only_shifts_path,
    "Shifts Calendar" => shifts_path,
    "New Shift" => new_shift_path,
    "Passengers" => passengers_path
  }

  path = title_to_path[page_title]
  raise "No known path for page title: '#{page_title}'" unless path

  visit path
end


Then("I should be on the {string} page") do |page_name|
  # actual_title = page.title
  # expect(actual_title).to eq(expected_title)
  # sleep 10

    path_map = {
    "Home" => root_path,
    "Log in" => new_user_session_path,
    "Sign up" => new_user_registration_path,
  }
  expected_path = path_map[page_name]
  raise "Unknown page name: #{page_name}" unless expected_path

  expect(current_path).to eq(expected_path)
end


When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I press {string}") do |button|
  click_button button
end

When("I click on {string} button") do |button_text|
  click_button(button_text) rescue click_link(button_text)
end

Then("I should see {string}") do |text|
  puts "Page content:\n#{page.text}"
  expect(page).to have_content(text)
end

Then("I should see {string} button") do |button_text|
  found = page.has_button?(button_text) || page.has_link?(button_text)
  expect(found).to be true
end

Given("there are no user exists with email {string}") do |email|
  User.find_by(email: email)&.destroy
end