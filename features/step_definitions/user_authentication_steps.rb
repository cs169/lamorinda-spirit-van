# frozen_string_literal: true

Given("the following user exists:") do |table|
  table.hashes.each do |row|
    User.create!(
      email: row["email"],
      password: row["password"],
      password_confirmation: row["password"],
      role: row["role"].presence
    )
  end
end

# features/step_definitions/auth_steps.rb
Given(/^an? (.*) is logged in$/) do |user_type|
  case user_type
  when "dispatcher"
    @user = FactoryBot.create(:user,
                            :dispatcher,
                            email: "dispatcher1@example.com",
                            password: "password")

  when "driver"
    @driver = FactoryBot.create(:driver)
    @driver_id = @driver.id
    @user = FactoryBot.create(:user,
                              :driver,
                              email: "driver1@example.com",
                              password: "password")
  when "admin"
    @user = FactoryBot.create(:user,
                              :admin,
                              email: "admin1@example.com",
                              password: "password")
  end

  visit new_user_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Log in"

  expect(page).not_to have_content("Log in")
  expect(page).to have_title("Lamorinda")
end
