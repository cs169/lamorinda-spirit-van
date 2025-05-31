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

      expect(ride.start_address).to be_a(Address)
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

      expect(ride.dest_address).to be_a(Address)
      expect(ride.dest_address.street).to eq("101 Market St")
      expect(ride.dest_address.city).to eq("San Francisco")
      expect(ride.dest_address.state).to eq("CA")
      expect(ride.dest_address.zip).to eq("94105")
    end
  end

  describe ".extract_attrs_from_params" do
    it "parses addresses and converts Yes/No fields into booleans" do
      raw_params = {
        date: "2025-05-01",
        van: "2",
        hours: "3",
        passenger_id: 1,
        driver_id: 1,
        notes: "Sample ride",
        emailed_driver: "sent",
        wheelchair: "Yes",
        low_income: "No",
        disabled: "Yes",
        need_caregiver: "No",
        addresses_attributes: [
          { street: "123 Main", city: "Oakland", state: "CA", zip: "94601" },
          { street: "456 Elm", city: "Berkeley", state: "CA", zip: "94704" }
        ]
      }

      input_params = ActionController::Parameters.new(raw_params).permit(
        :date, :van, :hours, :passenger_id, :driver_id, :notes, :emailed_driver,
        :wheelchair, :low_income, :disabled, :need_caregiver,
        addresses_attributes: [:street, :city, :state, :zip]
      )

      attrs, addresses = Ride.extract_attrs_from_params(input_params)

      expect(attrs[:wheelchair]).to eq(true)
      expect(attrs[:low_income]).to eq(false)
      expect(attrs[:disabled]).to eq(true)
      expect(attrs[:need_caregiver]).to eq(false)
      expect(attrs[:date]).to eq("2025-05-01")
      expect(attrs[:notes]).to eq("Sample ride")
      expect(addresses.length).to eq(2)
      expect(addresses.first[:city]).to eq("Oakland")
    end
  end

  describe "create multi-stop rides" do
    let(:ride_attrs) do
      {
        driver_id: 1,
        date: Time.zone.today,
        emailed_driver: "sent",
        confirmed_with_passenger: "Yes"
      }
    end

    it "creates a single ride with only two addresses" do
      a1 = FactoryBot.create(:address, street: "100 A", city: "Berkeley", state: "CA", zip: "94704")
      a2 = FactoryBot.create(:address, street: "200 B", city: "Berkeley", state: "CA", zip: "94704")

      addrs = [a1, a2]

      rides, success = Ride.build_linked_rides(ride_attrs, addrs)

      expect(rides.length).to eq(1)
      expect(success).to eq(true)

      expect(rides[0].start_address).to eq(a1)
      expect(rides[0].dest_address).to eq(a2)

      expect(rides[0].previous_ride).to eq(nil)
      expect(rides[0].next_ride).to eq(nil)
    end

    it "creates rides with and links them correctly" do
      address0 = FactoryBot.create(:address, street: "789 Broadway", city: "San Francisco", state: "CA", zip: "94133")
      address1 = FactoryBot.create(:address, street: "1000 Dwight", city: "Berkeley", state: "CA", zip: "94133")
      address2 = FactoryBot.create(:address, street: "100 Bancroft", city: "Berkeley", state: "CA", zip: "94133")
      address3 = FactoryBot.create(:address, street: "80 University", city: "Berkeley", state: "CA", zip: "94133")

      addrs = [address0, address1, address2, address3]

      rides, success  = Ride.build_linked_rides(ride_attrs, addrs)

      expect(rides.length).to eq(3)
      expect(success).to eq(true)

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
    end

    it "reuses the same address record when a stop appears multiple times" do
      shared_address = FactoryBot.create(:address, street: "123 Main", city: "Oakland", state: "CA", zip: "94607")
      another_address = FactoryBot.create(:address, street: "456 Elm", city: "Oakland", state: "CA", zip: "94607")

      addrs = [shared_address, another_address, shared_address] # same address used again

      rides, success = Ride.build_linked_rides(ride_attrs, addrs)

      expect(success).to eq(true)
      expect(rides.length).to eq(2)

      expect(rides[0].start_address_id).to eq(shared_address.id)
      expect(rides[0].dest_address_id).to eq(another_address.id)

      expect(rides[1].start_address_id).to eq(another_address.id)
      expect(rides[1].dest_address_id).to eq(shared_address.id)

      expect(rides[0].dest_address_id).not_to eq(rides[1].dest_address_id)
      expect(Address.where(street: "123 Main", city: "Oakland", state: "CA", zip: "94607").count).to eq(1)
    end
  end

  after(:each) do
    Ride.delete_all
    Driver.delete_all
  end
end
