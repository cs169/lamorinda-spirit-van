# frozen_string_literal: true

Given("the following passenger records exist:") do |table|
    table.hashes.each do |row|
      FactoryBot.create(:passenger,
        name: row["Name"],
        birthday: row["Birthday"],
        race: row["Race"],
        hispanic: row["Hispanic?"] == "true",
        date_registered: row["Date Registered"],
        address: FactoryBot.build(:address,
          street: row["Street"],
          city: row["City"],
          state: row["State"],
          zip: row["Zip"]
        )
      )
    end
  end

Given("I am on the new passenger page") do
  visit new_passenger_path
end

Given("I am on the master passenger list") do
  visit passengers_path
end

When("I fill in all neccesary information") do
  fill_in "Name", with: "New Passenger"
  fill_in "Street", with: "123 New St"
  fill_in "City", with: "Lafayette"
  fill_in "State", with: "CA"
  fill_in "Zip", with: "94549"
  fill_in "Birthday", with: "1950-01-01"
  fill_in "Race", with: 5
  select "Yes", from: "Hispanic?"
  fill_in "Date Registered", with: "2024-01-01"
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I press {string}") do |button|
  click_button button
end

When("I follow {string} for {string}") do |link_text, name|
  # Find the row containing the passenger’s name, then click the link
  within(:xpath, "//tr[td[contains(text(),'#{name}')]]") do
    click_link link_text
  end
end

Then("I should see {string}") do |text|
  expect(page).to have_content text
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content text
end
