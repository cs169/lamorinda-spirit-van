# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#role_home_path" do
    context "when no user is signed in" do
      it "returns root_path" do
        allow(helper).to receive(:user_signed_in?).and_return(false)
        allow(helper).to receive(:current_user).and_return(nil)
        expect(helper.role_home_path).to eq(root_path)
      end
    end

    context "when user is signed in" do
      let(:user) { FactoryBot.build_stubbed(:user, role: role) }

      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(user)
      end

      context "as admin" do
        let(:role) { "admin" }
        it { expect(helper.role_home_path).to eq(admin_users_path) }
      end

      context "as dispatcher" do
        let(:role) { "dispatcher" }
        it { expect(helper.role_home_path).to eq(rides_path) }
      end

      context "as driver" do
        let(:role) { "driver" }
        it { expect(helper.role_home_path).to eq(drivers_path) }
      end

      context "with unknown role" do
        let(:role) { "unknown" }
        it { expect(helper.role_home_path).to eq(root_path) }
      end
    end
  end
end
