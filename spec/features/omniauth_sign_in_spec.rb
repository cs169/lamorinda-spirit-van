# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in with Microsoft", type: :feature do
  it "admin logs in and redirects them successfully" do
    create(:user, :admin, email: "admin@example.com")

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
      provider: "entra_id",
      uid: "123545",
      info: {
        email: "admin@example.com",
        name: "Test Admin"
      }
    })

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("success")
    expect(current_path).to eq(admin_users_path)
  end

  it "dispatcher logs in and redirects them successfully" do
    create(:user, :dispatcher, email: "dispatcher@example.com")

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
      provider: "entra_id",
      uid: "123545",
      info: {
        email: "dispatcher@example.com",
        name: "Test Dispatcher"
      }
    })

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("success")
    expect(current_path).to eq(rides_path)
  end

  it "driver logs in and redirects them successfully" do
    create(:user, :dispatcher, email: "driver@example.com")

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
      provider: "entra_id",
      uid: "123545",
      info: {
        email: "driver@example.com",
        name: "Test Driver"
      }
    })

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("success")
    expect(current_path).to eq(rides_path)
  end

  it "does not allow login if user is not in system and has no role assigned" do
    create(:user, email: "randomuser@example.com", role: nil)

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
      provider: "entra_id",
      uid: "123545",
      info: {
        email: "randomuser@example.com",
        name: "Test Random"
      }
    })

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("Your account is awaiting role assignment. Please contact an admin.")
    expect(current_path).to eq(new_user_session_path)
  end

  it "handles OmniAuth failure -- user denies access or Microsoft errors" do
    OmniAuth.config.mock_auth[:entra_id] = :invalid_credentials

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("Could not authenticate you from EntraId")
    expect(current_path).to eq(new_user_session_path)
  end

  it "shows failure message if user creation fails" do
    allow(User).to receive(:create).and_return(User.new)

    OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new({
      provider: "entra_id",
      uid: "123545",
      info: {
        email: "randomuser@example.com",
        name: "Test Random"
      }
    })

    visit new_user_session_path
    find("button[title='Sign in with Microsoft']").click

    expect(page).to have_content("failed")
    expect(current_path).to eq(new_user_session_path)
  end
end
