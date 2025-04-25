# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User Authentication", type: :request do
  describe "POST /users (sign up)" do
    it "allows user to sign up and gets redirected to login page due to missing role" do
      post user_registration_path, params: {
        user: {
          email: "signupuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      # Follow Devise's auto-login redirection
      follow_redirect! # likely to root_path
      follow_redirect! # redirected by check_user_role to login

      # Final page should be the login page due to sign_out
      expect(response.body).to include("<title>Log in</title>")
    end
  end

  describe "POST /users/sign_in (sign in)" do
    before(:each) do
      @user = FactoryBot.create(:user, email: "withrole@example.com", password: "password", role: "driver")
    end

    it "signs in the user with correct credentials and triggers check_user_role" do
      post user_session_path, params: {
        user: {
          email: @user.email,
          password: "password"
        }
      }

      follow_redirect!

      # Simulate accessing a page after login to trigger check_user_role
      get root_path

      expect(response.body).to include("Lamorinda") # Adjust to your actual home page content
    end
  end
end
