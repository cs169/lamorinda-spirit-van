# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    before_action -> { capture_return_to(:custom_return_to) }, only: :index

    def index
      render plain: "OK"
    end
  end

  describe "#after_sign_in_path_for" do
    before do
      @admin      = FactoryBot.build_stubbed(:user, role: "admin")
      @dispatcher = FactoryBot.build_stubbed(:user, role: "dispatcher")
      @driver     = FactoryBot.build_stubbed(:user, role: "driver")
      @no_role    = FactoryBot.build_stubbed(:user, role: nil)
    end

    it "redirects admin to admin homepage" do
      result = controller.send(:after_sign_in_path_for, @admin)
      expect(result).to eq(root_path)
    end

    it "redirects dispatcher to dispatcher homepage" do
      result = controller.send(:after_sign_in_path_for, @dispatcher)
      expect(result).to eq(root_path)
    end

    it "redirects driver to driver homepage" do
      result = controller.send(:after_sign_in_path_for, @driver)
      expect(result).to eq(root_path)
    end

    it "redirects users with no role to default homepage" do
      result = controller.send(:after_sign_in_path_for, @no_role)
      expect(result).to eq(root_path)
    end
  end

  describe "#capture_return_to" do
    before do
      @user = FactoryBot.create(:user, role: "dispatcher")
      sign_in @user
    end

    context "when params has the return_to parameter" do
      it "stores the return_to value into session and sets instance variable" do
        test_path = "/drivers/1/today?date=2025-04-29"
        get :index, params: { custom_return_to: test_path }

        expect(session[:custom_return_to]).to eq(test_path)
        expect(assigns(:custom_return_to)).to eq(test_path)
      end
    end

    context "when params does not have the return_to parameter" do
      it "does not modify session or set instance variable" do
        get :index

        expect(session[:custom_return_to]).to be_nil
        expect(assigns(:custom_return_to)).to be_nil
      end
    end
  end
end
