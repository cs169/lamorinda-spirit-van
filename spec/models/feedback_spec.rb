# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback, type: :model do
  describe "associations" do
    it "belongs to a ride" do
      ride = FactoryBot.create(:ride)
      feedback = ride.feedback
      expect(feedback.ride).to eq(ride)
    end
  end

  describe "MOBILITY_OPTIONS" do
    it "is a frozen array containing the expected mobility values" do
      expect(Feedback::MOBILITY_OPTIONS).to eq([ "Walker", "Cane", "Wheelchair", "None" ])
      expect(Feedback::MOBILITY_OPTIONS).to be_frozen
    end
  end
end
