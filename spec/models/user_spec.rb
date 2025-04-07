# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#admin?" do
    it "returns true when role is admin" do
      user = User.new(role: "admin")
      expect(user.admin?).to be true
    end

    it "returns false when role is not admin" do
      user = User.new(role: "driver")
      expect(user.admin?).to be false
    end
  end

  describe "#dispatcher?" do
    it "returns true when role is dispatcher" do
      user = User.new(role: "dispatcher")
      expect(user.dispatcher?).to be true
    end

    it "returns false when role is not dispatcher" do
      user = User.new(role: "admin")
      expect(user.dispatcher?).to be false
    end
  end

  describe "#driver?" do
    it "returns true when role is driver" do
      user = User.new(role: "driver")
      expect(user.driver?).to be true
    end

    it "returns false when role is not driver" do
      user = User.new(role: "dispatcher")
      expect(user.driver?).to be false
    end
  end
end
