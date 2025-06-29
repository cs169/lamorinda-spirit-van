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
      date: Date.current,
    )
    @ride2 = FactoryBot.create(
      :ride,
      driver: @driver2,
    )
    @ride3 = FactoryBot.create(
      :ride,
      driver: @driver1,
      date: Date.current,
      wheelchair: true,
      need_caregiver: true
    )
  end

  describe "after_create" do
    it "automatically creates a corresponding Feedback upon Ride creation" do
      ride = FactoryBot.create(:ride, driver: @driver1)
      expect(ride.feedback).not_to be_nil
      expect(ride.feedback).to be_an_instance_of(Feedback)
    end
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(@ride1).to be_valid
    end

    it "checks wheelchair and needs_caregiver fields" do
      expect(@ride3.wheelchair).to eq(true)
      expect(@ride3.need_caregiver).to eq(true)
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
        date: "2025-05-01",
        van: 2,
        hours: "3",
        passenger_id: 1,
        driver_id: 1,
        notes: "Sample ride",
        notes_to_driver: "Sample ride",
        ride_type: "Default",
        fare_type: "Default",
        wheelchair: "Yes",
        disabled: "Yes",
        need_caregiver: "No",
        addresses_attributes: [
          { name: "Origin", street: "123 Main", city: "Oakland", phone: "(123)456-7890" },
          { name: "Destination", street: "456 Elm", city: "Berkeley", phone: "(456)123-1234" }
        ]
      }

      input_params = ActionController::Parameters.new(raw_params).permit(
        :date, :van, :hours, :passenger_id, :driver_id, :notes, :notes_to_driver,
        :ride_type, :fare_type, :wheelchair, :disabled, :need_caregiver,
        addresses_attributes: [:name, :street, :city, :phone]
      )

      attrs, addresses, _ = Ride.extract_attrs_from_params(input_params)

      expect(attrs[:wheelchair]).to eq(true)
      expect(attrs[:disabled]).to eq(true)
      expect(attrs[:need_caregiver]).to eq(false)
      expect(attrs[:date]).to eq("2025-05-01")
      expect(attrs[:notes]).to eq("Sample ride")
      expect(attrs[:notes_to_driver]).to eq("Sample ride")
      expect(attrs[:ride_type]).to eq("Default")
      expect(attrs[:fare_type]).to eq("Default")
      expect(addresses.length).to eq(2)
      expect(addresses.first[:city]).to eq("Oakland")
    end

    it "handles stops_attributes parameter and returns three values" do
      raw_params = {
        date: "2025-05-01",
        van: 2,
        hours: "3",
        passenger_id: 1,
        driver_id: 1,
        notes: "Sample ride",
        wheelchair: "No",
        disabled: "No",
        need_caregiver: "No",
        addresses_attributes: [
          { name: "Origin", street: "123 Main", city: "Oakland", phone: "(123)456-7890" },
          { name: "Stop 1", street: "456 Elm", city: "Berkeley", phone: "(456)123-1234" },
          { name: "Stop 2", street: "789 Oak", city: "San Francisco", phone: "(789)456-7890" }
        ],
        stops_attributes: [
          { driver_id: "2", van: 1 },
          { driver_id: "3", van: 2 }
        ]
      }

      input_params = ActionController::Parameters.new(raw_params).permit(
        :date, :van, :hours, :passenger_id, :driver_id, :notes, :notes_to_driver,
        :ride_type, :fare_type, :wheelchair, :disabled, :need_caregiver,
        addresses_attributes: [:name, :street, :city, :phone],
        stops_attributes: [:driver_id, :van]
      )

      attrs, addresses, stops_data = Ride.extract_attrs_from_params(input_params)

      expect(attrs[:wheelchair]).to eq(false)
      expect(attrs[:disabled]).to eq(false)
      expect(attrs[:need_caregiver]).to eq(false)
      expect(addresses.length).to eq(3)
      expect(stops_data.length).to eq(2)
      expect(stops_data[0][:driver_id]).to eq("2")
      expect(stops_data[0][:van]).to eq(1)
      expect(stops_data[1][:driver_id]).to eq("3")
      expect(stops_data[1][:van]).to eq(2)
    end

    it "returns empty array when stops_attributes is not present" do
      raw_params = {
        date: "2025-05-01",
        van: 2,
        driver_id: 1,
        addresses_attributes: [
          { name: "Origin", street: "123 Main", city: "Oakland" },
          { name: "Destination", street: "456 Elm", city: "Berkeley" }
        ]
      }

      input_params = ActionController::Parameters.new(raw_params).permit(
        :date, :van, :driver_id,
        addresses_attributes: [:name, :street, :city, :phone]
      )

      _, addresses, stops_data = Ride.extract_attrs_from_params(input_params)

      expect(stops_data).to eq([])
      expect(addresses.length).to eq(2)
    end
  end

  describe "create multi-stop rides" do
    let(:ride_attrs) do
      {
        driver_id: 1,
        date: Date.current,
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

      expect(rides[0].start_address.address_no_zip).to eq("(Kaiser) 789 Broadway, San Francisco")
      expect(rides[0].dest_address.address_no_zip).to eq("(Kaiser) 1000 Dwight, Berkeley")

      expect(rides[1].start_address.address_no_zip).to eq("(Kaiser) 1000 Dwight, Berkeley")
      expect(rides[1].dest_address.address_no_zip).to eq("(Kaiser) 100 Bancroft, Berkeley")

      expect(rides[2].start_address.address_no_zip).to eq("(Kaiser) 100 Bancroft, Berkeley")
      expect(rides[2].dest_address.address_no_zip).to eq("(Kaiser) 80 University, Berkeley")

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

    context "with per-stop driver and van assignment" do
      it "assigns different drivers and vans to each stop" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver1.id, van: 1 },
          { driver_id: @driver2.id, van: 2 }
        ]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs, stops_data)

        expect(success).to eq(true)
        expect(rides.length).to eq(2)

        # First ride: address1 -> address2 with driver1 and van 1
        expect(rides[0].start_address).to eq(address1)
        expect(rides[0].dest_address).to eq(address2)
        expect(rides[0].driver_id).to eq(@driver1.id)
        expect(rides[0].van).to eq(1)

        # Second ride: address2 -> address3 with driver2 and van 2
        expect(rides[1].start_address).to eq(address2)
        expect(rides[1].dest_address).to eq(address3)
        expect(rides[1].driver_id).to eq(@driver2.id)
        expect(rides[1].van).to eq(2)

        # Verify linking
        expect(rides[0].next_ride).to eq(rides[1])
        expect(rides[1].previous_ride).to eq(rides[0])
      end

      it "uses base ride attributes when stops_data is insufficient" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver2.id, van: 5 }
          # Only one stop specified, second should use base attributes
        ]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs, stops_data)

        expect(success).to eq(true)
        expect(rides.length).to eq(2)

        # First ride uses stops_data
        expect(rides[0].driver_id).to eq(@driver2.id)
        expect(rides[0].van).to eq(5)

        # Second ride uses base ride_attrs
        expect(rides[1].driver_id).to eq(ride_attrs[:driver_id])
        expect(rides[1].van).to be_nil # base attrs don't include van
      end

      it "handles partial stops_data with only driver_id specified" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 End", city: "Oakland")

        addrs = [address1, address2]
        stops_data = [
          { driver_id: @driver2.id } # van not specified
        ]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs, stops_data)

        expect(success).to eq(true)
        expect(rides.length).to eq(1)
        expect(rides[0].driver_id).to eq(@driver2.id)
        expect(rides[0].van).to be_nil # not specified in stops_data
      end

      it "handles partial stops_data with only van specified" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 End", city: "Oakland")

        addrs = [address1, address2]
        stops_data = [
          { van: 3 } # driver_id not specified
        ]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs, stops_data)

        expect(success).to eq(true)
        expect(rides.length).to eq(1)
        expect(rides[0].driver_id).to eq(ride_attrs[:driver_id]) # uses base
        expect(rides[0].van).to eq(3)
      end

      it "ignores empty stops_data entries" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          {}, # empty hash
          { driver_id: @driver2.id, van: 7 }
        ]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs, stops_data)

        expect(success).to eq(true)
        expect(rides.length).to eq(2)

        # First ride uses base attributes (empty stops_data entry ignored)
        expect(rides[0].driver_id).to eq(ride_attrs[:driver_id])

        # Second ride uses stops_data
        expect(rides[1].driver_id).to eq(@driver2.id)
        expect(rides[1].van).to eq(7)
      end

      it "works with no stops_data provided (backward compatibility)" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 End", city: "Oakland")

        addrs = [address1, address2]

        rides, success = Ride.build_linked_rides(ride_attrs, addrs) # no stops_data

        expect(success).to eq(true)
        expect(rides.length).to eq(1)
        expect(rides[0].driver_id).to eq(ride_attrs[:driver_id])
      end
    end
  end

  describe "linked ride driver and van aggregation methods" do
    before(:each) do
      @driver3 = FactoryBot.create(:driver, name: "Third Driver")
    end

    describe "#all_drivers_names" do
      it "returns single driver name for a ride with no linked rides" do
        ride = FactoryBot.create(:ride, driver: @driver1)
        expect(ride.all_drivers_names).to eq(@driver1.name)
      end

      it "returns all unique driver names from linked rides" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver1.id, van: 1 },
          { driver_id: @driver2.id, van: 2 }
        ]

        rides, success = Ride.build_linked_rides({ driver_id: @driver1.id, date: Date.current }, addrs, stops_data)
        expect(success).to eq(true)

        # Test from first ride in chain
        expect(rides[0].all_drivers_names).to eq("#{@driver1.name}, #{@driver2.name}")
        
      end

      it "returns unique driver names when same driver appears multiple times" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver1.id, van: 1 },
          { driver_id: @driver1.id, van: 3 } # Same driver, different van
        ]

        rides, success = Ride.build_linked_rides({ driver_id: @driver1.id, date: Date.current }, addrs, stops_data)
        expect(success).to eq(true)

        expect(rides[0].all_drivers_names).to eq(@driver1.name)
      end

    end

    describe "#all_vans_numbers" do
      it "returns single van number for a ride with no linked rides" do
        ride = FactoryBot.create(:ride, van: 5)
        expect(ride.all_vans_numbers).to eq("5")
      end

      it "returns all unique van numbers from linked rides" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver1.id, van: 2 },
          { driver_id: @driver2.id, van: 5 }
        ]

        rides, success = Ride.build_linked_rides({ driver_id: @driver1.id, date: Date.current }, addrs, stops_data)
        expect(success).to eq(true)

        # Test from first ride in chain
        expect(rides[0].all_vans_numbers).to eq("2, 5")
      end

      it "returns unique van numbers when same van appears multiple times" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 End", city: "San Francisco")

        addrs = [address1, address2, address3]
        stops_data = [
          { driver_id: @driver1.id, van: 3 },
          { driver_id: @driver2.id, van: 3 } # Same van, different driver
        ]

        rides, success = Ride.build_linked_rides({ driver_id: @driver1.id, date: Date.current }, addrs, stops_data)
        expect(success).to eq(true)

        expect(rides[0].all_vans_numbers).to eq("3")
      end

      it "handles rides with nil vans gracefully" do
        ride1 = FactoryBot.create(:ride, van: 7)
        ride2 = FactoryBot.create(:ride, van: nil)
        
        # Manually link the rides
        ride1.update!(next_ride: ride2)

        expect(ride1.all_vans_numbers).to eq("7")
      end

      it "returns empty string when all rides have nil vans" do
        ride1 = FactoryBot.create(:ride, van: nil)
        ride2 = FactoryBot.create(:ride, van: nil)
        
        # Manually link the rides
        ride1.update!(next_ride: ride2)

        expect(ride1.all_vans_numbers).to eq("")
      end
    end

    describe "integration with linked rides containing three stops" do
      it "correctly aggregates drivers and vans from a three-ride chain" do
        address1 = FactoryBot.create(:address, street: "100 Start", city: "Berkeley")
        address2 = FactoryBot.create(:address, street: "200 Middle", city: "Oakland")
        address3 = FactoryBot.create(:address, street: "300 Almost End", city: "San Francisco")
        address4 = FactoryBot.create(:address, street: "400 End", city: "San Jose")

        addrs = [address1, address2, address3, address4]
        stops_data = [
          { driver_id: @driver1.id, van: 1 },
          { driver_id: @driver2.id, van: 2 },
          { driver_id: @driver3.id, van: 3 }
        ]

        rides, success = Ride.build_linked_rides({ driver_id: @driver1.id, date: Date.current }, addrs, stops_data)
        expect(success).to eq(true)
        expect(rides.length).to eq(3)

        # Test from any ride in the chain
        expected_drivers = "#{@driver1.name}, #{@driver2.name}, #{@driver3.name}"
        expect(rides[0].all_drivers_names).to eq(expected_drivers)

        expected_vans = "1, 2, 3"
        expect(rides[0].all_vans_numbers).to eq(expected_vans)
      end
    end
  end
end
