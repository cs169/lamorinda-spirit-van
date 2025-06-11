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
      date_and_time: Time.zone.today.yesterday.noon,
    )
    @ride2 = FactoryBot.create(
      :ride,
      driver: @driver2,
    )
    @ride3 = FactoryBot.create(
      :ride,
      driver: @driver1,
      date_and_time: Time.zone.today.tomorrow.noon,
      wheelchair: true,
      low_income: true
    )
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(@ride1).to be_valid
    end

    it "checks wheelchair and low_income fields" do
      expect(@ride3.wheelchair).to eq(true)
      expect(@ride3.low_income).to eq(true)
    end
  end

  describe "#start_address_attributes=" do
    it "assigns existing address if found" do
      existing_address = FactoryBot.create(:address, name: "Kaiser", street: "123 Main St", city: "Berkeley", phone: "(123)456-7890")
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.start_address_attributes = {
        name: "Kaiser",
        street: " 123 main st ",
        city: "berkeley",
        phone: "(123)456-7890",
      }

      expect(ride.start_address).to eq(existing_address)
    end

    it "builds a new address if not found" do
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.start_address_attributes = {
        name: "New",
        street: " 456 new ave ",
        city: "oakland",
        phone: "(123)412-1231"
      }

      expect(ride.start_address).to be_a(Address)
      expect(ride.start_address.name).to eq("New")
      expect(ride.start_address.street).to eq("456 New Ave")
      expect(ride.start_address.city).to eq("Oakland")
      expect(ride.start_address.phone).to eq("(123)412-1231")
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
      existing_address = FactoryBot.create(:address, name: "Library", street: "789 Broadway", city: "San Francisco", phone: "(123)456-7890")
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.dest_address_attributes = {
        name: "Library",
        street: "789 broadway",
        city: "san francisco",
        phone: "(123)456-7890",
      }

      expect(ride.dest_address).to eq(existing_address)
    end

    it "builds a new address if not found" do
      ride = FactoryBot.build(:ride, driver: @driver1)

      ride.dest_address_attributes = {
        name: "New Addy",
        street: " 101 market st ",
        city: "san francisco",
        phone: "(123)456-7890"
      }

      expect(ride.dest_address).to be_a(Address)
      expect(ride.dest_address.name).to eq("New Addy")
      expect(ride.dest_address.street).to eq("101 Market St")
      expect(ride.dest_address.city).to eq("San Francisco")
      expect(ride.dest_address.phone).to eq("(123)456-7890")
    end
  end

  describe ".extract_attrs_from_params" do
    it "parses addresses and converts Yes/No fields into booleans" do
      raw_params = {
        date_and_time: "2025-05-01 10:00 AM",
        van: "2",
        hours: "3",
        passenger_id: 1,
        driver_id: 1,
        notes: "Sample ride",
        notes_to_driver: "Sample ride",
        wheelchair: "Yes",
        low_income: "No",
        disabled: "Yes",
        need_caregiver: "No",
        addresses_attributes: [
          { name: "Origin", street: "123 Main", city: "Oakland", phone: "(123)456-7890" },
          { name: "Destination", street: "456 Elm", city: "Berkeley", phone: "(456)123-1234" }
        ]
      }

      input_params = ActionController::Parameters.new(raw_params).permit(
        :date_and_time, :van, :hours, :passenger_id, :driver_id, :notes, :notes_to_driver,
        :wheelchair, :low_income, :disabled, :need_caregiver,
        addresses_attributes: [:name, :street, :city, :phone]
      )

      attrs, addresses = Ride.extract_attrs_from_params(input_params)

      expect(attrs[:wheelchair]).to eq(true)
      expect(attrs[:low_income]).to eq(false)
      expect(attrs[:disabled]).to eq(true)
      expect(attrs[:need_caregiver]).to eq(false)
      expect(attrs[:date_and_time]).to eq("2025-05-01 10:00 AM")
      expect(attrs[:notes]).to eq("Sample ride")
      expect(addresses.length).to eq(2)
      expect(addresses.first[:city]).to eq("Oakland")
    end
  end

  describe "create multi-stop rides" do
    let(:ride_attrs) do
      {
        driver_id: 1,
        date_and_time: Time.zone.today.noon,
      }
    end

    it "creates a single ride with only two addresses" do
      a1 = FactoryBot.create(:address, street: "100 A", city: "Berkeley")
      a2 = FactoryBot.create(:address, street: "200 B", city: "Berkeley")

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
      address0 = FactoryBot.create(:address, street: "789 Broadway", city: "San Francisco")
      address1 = FactoryBot.create(:address, street: "1000 Dwight", city: "Berkeley")
      address2 = FactoryBot.create(:address, street: "100 Bancroft", city: "Berkeley")
      address3 = FactoryBot.create(:address, street: "80 University", city: "Berkeley")

      addrs = [address0, address1, address2, address3]

      rides, success  = Ride.build_linked_rides(ride_attrs, addrs)

      expect(rides.length).to eq(3)
      expect(success).to eq(true)

      expect(rides[0].start_address.full_address).to eq("(Kaiser) 789 Broadway, San Francisco")
      expect(rides[0].dest_address.full_address).to eq("(Kaiser) 1000 Dwight, Berkeley")

      expect(rides[1].start_address.full_address).to eq("(Kaiser) 1000 Dwight, Berkeley")
      expect(rides[1].dest_address.full_address).to eq("(Kaiser) 100 Bancroft, Berkeley")

      expect(rides[2].start_address.full_address).to eq("(Kaiser) 100 Bancroft, Berkeley")
      expect(rides[2].dest_address.full_address).to eq("(Kaiser) 80 University, Berkeley")

      expect(rides[0].next_ride).to eq(rides[1])
      expect(rides[1].previous_ride).to eq(rides[0])

      expect(rides[1].next_ride).to eq(rides[2])
      expect(rides[2].previous_ride).to eq(rides[1])

      expect(rides[0].previous_ride).to eq(nil)
      expect(rides[2].next_ride).to eq(nil)
    end

    it "reuses the same address record when a stop appears multiple times" do
      shared_address = FactoryBot.create(:address, street: "123 Main", city: "Oakland")
      another_address = FactoryBot.create(:address, street: "456 Elm", city: "Oakland")

      addrs = [shared_address, another_address, shared_address] # same address used again

      rides, success = Ride.build_linked_rides(ride_attrs, addrs)

      expect(success).to eq(true)
      expect(rides.length).to eq(2)

      expect(rides[0].start_address_id).to eq(shared_address.id)
      expect(rides[0].dest_address_id).to eq(another_address.id)

      expect(rides[1].start_address_id).to eq(another_address.id)
      expect(rides[1].dest_address_id).to eq(shared_address.id)

      expect(rides[0].dest_address_id).not_to eq(rides[1].dest_address_id)
      expect(Address.where(street: "123 Main", city: "Oakland").count).to eq(1)
    end
  end

  after(:each) do
    Ride.delete_all
    Driver.delete_all
  end
end
