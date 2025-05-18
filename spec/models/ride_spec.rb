# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ride, type: :model do
  before(:each) do
    @driver1 = FactoryBot.create(:driver)
    @driver2 = FactoryBot.create(:driver)

    today = Time.zone.today
    today.strftime("%a")

    @shift_yesterday = FactoryBot.create(:shift, driver: @driver1, date: Time.zone.today - 1.day, emailed_driver: true)
    @shift_today =  FactoryBot.create(:shift, driver: @driver2)
    @shift_tomorrow = FactoryBot.create(:shift, driver: @driver1, date: Time.zone.today + 1.day)

    @ride1 = FactoryBot.create(:ride, shift: @shift_yesterday)
    @ride2 = FactoryBot.create(:ride, shift: @shift_today)
    @ride3 = FactoryBot.create(:ride, shift: @shift_tomorrow)
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(@ride1).to be_valid
    end

    it "is certain fields valid" do
      expect(@ride1.emailed_driver?).to eq(true)
    end
  end

  describe "#start_address_attributes=" do
    it "assigns existing address if found" do
      existing_address = FactoryBot.create(:address, street: "123 Main St", city: "Berkeley", state: "CA", zip: "94704")
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.start_address_attributes = {
        street: " 123 main st ",
        city: "berkeley",
        state: "ca",
        zip: "94704"
      }

      expect(ride.start_address).to eq(existing_address)
    end

    it "builds a new address if not found" do
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.start_address_attributes = {
        street: " 456 new ave ",
        city: "oakland",
        state: "ca",
        zip: "94607"
      }

      expect(ride.start_address).to be_a_new(Address)
      expect(ride.start_address.street).to eq("456 New Ave")
      expect(ride.start_address.city).to eq("Oakland")
      expect(ride.start_address.state).to eq("CA")
      expect(ride.start_address.zip).to eq("94607")
    end
  end

  describe "#dest_address_attributes=" do
    it "assigns existing address if found" do
      existing_address = FactoryBot.create(:address, street: "789 Broadway", city: "San Francisco", state: "CA", zip: "94133")
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.dest_address_attributes = {
        street: "789 broadway",
        city: "san francisco",
        state: "ca",
        zip: "94133"
      }

      expect(ride.dest_address).to eq(existing_address)
    end

    it "builds a new address if not found" do
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.dest_address_attributes = {
        street: " 101 market st ",
        city: "san francisco",
        state: "ca",
        zip: "94105"
      }

      expect(ride.dest_address).to be_a_new(Address)
      expect(ride.dest_address.street).to eq("101 Market St")
      expect(ride.dest_address.city).to eq("San Francisco")
      expect(ride.dest_address.state).to eq("CA")
      expect(ride.dest_address.zip).to eq("94105")
    end
  end
end
