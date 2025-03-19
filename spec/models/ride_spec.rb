# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ride, type: :model do
  before(:each) do
    @driver1 = Driver.create(name: "Driver A", phone: "1234567890", email: "jd@lamorinda.com", active: true)
    @driver2 = Driver.create(name: "Driver B", phone: "1234567890", email: "jd@lamorinda.com", active: true)

    today = Time.zone.today
    weekday_abbreviation = today.strftime("%a")

    @ride1 = Ride.create!(day: weekday_abbreviation, date: today - 1.day, driver: @driver1.name, van: 6,
                          passenger_name_and_phone: "John Doe (555-123-4567)", passenger_address: "456 Oak St.",
                          destination: "Pleasant Hill", notes_to_driver: "Call before arriving",
                          driver_initials: "JD", hours: 2.0, amount_paid: 25.0, ride_count: 1,
                          c: "C", notes_date_reserved: "02/28/2025", confirmed_with_passenger: "Yes", driver_email: "sent")

    @ride2 = Ride.create!(day: weekday_abbreviation, date: today, driver: @driver2.name, van: 6,
                          passenger_name_and_phone: "Jane Doe (555-987-6543)", passenger_address: "789 Maple St.",
                          destination: "Lafayette", notes_to_driver: "Be on time",
                          driver_initials: "JD", hours: 1.5, amount_paid: 20.0, ride_count: 1,
                          c: "C", notes_date_reserved: "02/28/2025", confirmed_with_passenger: "Yes", driver_email: "sent")

    @ride3 = Ride.create!(day: weekday_abbreviation, date: today, driver: @driver1.name, van: 6,
                          passenger_name_and_phone: "Alice Brown (555-444-1111)", passenger_address: "123 Pine St.",
                          destination: "Walnut Creek", notes_to_driver: "Text when arriving",
                          driver_initials: "JD", hours: 1.0, amount_paid: 15.0, ride_count: 1,
                          c: "C", notes_date_reserved: "02/28/2025", confirmed_with_passenger: "Yes", driver_email: "sent")

    @ride4 = Ride.create!(day: weekday_abbreviation, date: today + 1.day, driver: @driver1.name, van: 6,
                          passenger_name_and_phone: "Alice Brown (555-444-1111)", passenger_address: "123 Pine St.",
                          destination: "Walnut Creek", notes_to_driver: "Text when arriving",
                          driver_initials: "JD", hours: 1.0, amount_paid: 15.0, ride_count: 1,
                          c: "C", notes_date_reserved: "02/28/2025", confirmed_with_passenger: "Yes", driver_email: "sent")
  end

  describe "Validations" do
    it "is valid with all required attributes" do
      expect(@ride1).to be_valid
    end

    it "is invalid without a day" do
      ride = Ride.new(date: Time.zone.today, passenger_name_and_phone: "John Doe (555-123-4567)")
      expect(ride).not_to be_valid
      expect(ride.errors[:day]).to include("can't be blank")
    end

    it "is invalid without a date" do
      ride = Ride.new(day: "F", passenger_name_and_phone: "John Doe (555-123-4567)")
      expect(ride).not_to be_valid
      expect(ride.errors[:date]).to include("can't be blank")
    end

    it "is invalid without passenger_name_and_phone" do
      ride = Ride.new(day: "F", date: Time.zone.today)
      expect(ride).not_to be_valid
      expect(ride.errors[:passenger_name_and_phone]).to include("can't be blank")
    end
  end

  describe ".rides_by_date" do
    it "returns rides that are scheduled for today" do
      rides = Ride.rides_by_date(Ride.all, Time.zone.today)
      expect(rides).to match_array([ @ride2, @ride3 ])
    end

    it "returns rides that are scheduled for yesterday" do
      rides = Ride.rides_by_date(Ride.all, Time.zone.today - 1.day)
      expect(rides).to match_array([ @ride1 ])
    end

    it "returns rides that are scheduled for tomorrow" do
      rides = Ride.rides_by_date(Ride.all, Time.zone.today + 1.day)
      expect(rides).to match_array([ @ride4 ])
    end
  end

  describe ".rides_by_driver" do
    it "returns rides for a given driver" do
      rides = Ride.rides_by_driver(Ride.all, "Driver A")
      expect(rides).to match_array([ @ride1, @ride3, @ride4 ])
    end

    it "returns all rides when driver_name is nil" do
      rides = Ride.rides_by_driver(Ride.all, nil)
      expect(rides).to match_array([ @ride1, @ride2, @ride3, @ride4 ])
    end
  end

  describe ".driver_today_view" do
    it "returns all rides when no filters are applied" do
      rides = Ride.driver_today_view(nil)
      expect(rides).to match_array([@ride2, @ride3])
    end
  end

  after(:each) do
    Ride.delete_all
    Driver.delete_all
  end
end
