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
          zip_code: row["Zip"]
        )
      )
    end
  end


When("I fill in all necessary information") do
  fill_in "Name", with: "New Passenger"
  fill_in "Street", with: "123 New St"
  fill_in "City", with: "Lafayette"
  fill_in "Zip Code", with: "94595"
  fill_in "Birthday", with: "1950-01-01"
  fill_in "Race", with: 5
  select "Yes", from: "Hispanic?"
  fill_in "Date Registered", with: "2024-01-01"
  select "No", from: "LMV Member?"
  fill_in "Mail Updates", with: "Monthly newsletter"
  select "Opt-In", from: "Requested Newsletter"
end


When(/^I follow "(Edit|Delete)" for "([^"]+) ([^"]+)"$/) do |link_text, first, last|
  # Find the row containing the passenger's name, then click the link
  within(:xpath, "//tr[td[contains(text(),'#{first}')] and td[contains(text(),'#{last}')]]") do
    click_link link_text
  end
end
