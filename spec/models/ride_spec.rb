# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ride, type: :model do
  before(:each) do
    @driver1 = FactoryBot.create(:driver)
    @driver2 = FactoryBot.create(:driver)

    today = Time.zone.today
    today.strftime("%a")

    @ride1 = FactoryBot.create(
      :ride,
      driver: @driver1,
      date: Time.zone.today - 1.day,
      emailed_driver: "sent",
      confirmed_with_passenger: "Yes"
    )
    @ride2 = FactoryBot.create(
      :ride,
      driver: @driver2,
      confirmed_with_passenger: "No"
    )
    @ride3 = FactoryBot.create(
      :ride,
      driver: @driver1,
      date: Time.zone.today + 1.day,
      wheelchair: true,
      low_income: true
    )
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(@ride1).to be_valid
    end

    it "is certain fields valid" do
      expect(@ride1.emailed_driver).to eq("sent")
    end

    it "checks confirmed_with_passenger field" do
      expect(@ride1.confirmed_with_passenger).to eq("Yes")
      expect(@ride2.confirmed_with_passenger).to eq("No")
    end

    it "checks wheelchair and low_income fields" do
      expect(@ride3.wheelchair).to eq(true)
      expect(@ride3.low_income).to eq(true)
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

  describe "Associations" do
    it "belongs to a driver" do
      expect(@ride1.driver).to eq(@driver1)
    end

    it "belongs to a passenger" do
      expect(@ride2.passenger).to be_present
    end
  end

  describe "Scopes" do
    it "retrieves rides for a specific driver" do
      expect(Ride.where(driver: @driver1)).to include(@ride1, @ride3)
      expect(Ride.where(driver: @driver2)).to include(@ride2)
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

  describe "create multi-stop rides" do
    it "creates rides and links them correctly" do
      address0 = FactoryBot.create(:address, street: "789 Broadway", city: "San Francisco", state: "CA", zip: "94133")
      address1 = FactoryBot.create(:address, street: "1000 Dwight", city: "Berkeley", state: "CA", zip: "94133")
      address2 = FactoryBot.create(:address, street: "100 Bancroft", city: "Berkeley", state: "CA", zip: "94133")
      address3 = FactoryBot.create(:address, street: "80 University", city: "Berkeley", state: "CA", zip: "94133")

      addrs = [address0, address1, address2, address3]
      ride_attrs = {
        driver_id: 1,
        date: Time.zone.today - 1.day,
        emailed_driver: "sent",
        confirmed_with_passenger: "Yes"
      }
      rides = Ride.build_linked_rides(ride_attrs, addrs)
     
      Ride.save_rides(rides)

      expect(rides.length).to eq(3)

      expect(rides[0].start_address.full_address).to eq("789 Broadway, San Francisco, CA, 94133")
      expect(rides[0].dest_address.full_address).to eq("1000 Dwight, Berkeley, CA, 94133")

      expect(rides[1].start_address.full_address).to eq("1000 Dwight, Berkeley, CA, 94133")
      expect(rides[1].dest_address.full_address).to eq("100 Bancroft, Berkeley, CA, 94133")

      expect(rides[2].start_address.full_address).to eq("100 Bancroft, Berkeley, CA, 94133")
      expect(rides[2].dest_address.full_address).to eq("80 University, Berkeley, CA, 94133")

      expect(rides[0].next_ride).to eq(rides[1])
      expect(rides[1].previous_ride).to eq(rides[0])

      expect(rides[1].next_ride).to eq(rides[2])
      expect(rides[2].previous_ride).to eq(rides[1])

      expect(rides[0].previous_ride).to eq(nil)
      expect(rides[2].next_ride).to eq(nil)

      byebug
    end
  end

  after(:each) do
    Ride.delete_all
    Driver.delete_all
  end
end
