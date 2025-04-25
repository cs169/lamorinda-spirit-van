# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
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

    it "redirects users with no role to defalut homepage" do
      result = controller.send(:after_sign_in_path_for, @no_role)
      expect(result).to eq(root_path)
    end
  end
end
