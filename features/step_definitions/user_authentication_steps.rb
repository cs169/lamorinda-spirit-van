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
Given("a dispatcher is logged in") do
  @dispatcher = FactoryBot.create(:user,
                                  :dispatcher,
                                  email: "dispatcher1@example.com",
                                  password: "password")
  visit new_user_session_path

  fill_in "Email", with: @dispatcher.email
  fill_in "Password", with: @dispatcher.password
  click_button "Log in"

  expect(page).not_to have_content("Log in")
  expect(page).to have_title("Lamorinda")
end

Given("a driver is logged in") do
  @driver = FactoryBot.create(:driver)
  @driver_id = @driver.id
  @user = FactoryBot.create(
    :user,
    :driver,
    email: "driver1@example.com",
    password: "password"
  )

  visit new_user_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: @user.password
  click_button "Log in"

  expect(page).not_to have_content("Log in")
  expect(page).to have_title("Lamorinda")
  expect(page).to have_current_path(root_path)
end
