# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shift, type: :model do
  before(:each) do
    @driver = FactoryBot.create(:driver)
  end

  context "validations" do
    it "is valid with valid attributes" do
      shift = Shift.new(shift_date: Date.today, shift_type: "am", driver: @driver)
      expect(shift).to be_valid
    end

    it "is invalid without a shift_date" do
      shift = Shift.new(shift_date: nil, shift_type: "am", driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:shift_date]).to include("can't be blank")
    end

    it "is invalid without a shift_type" do
      shift = Shift.new(shift_date: Date.today, shift_type: nil, driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:shift_type]).to include("can't be blank")
    end

    it "is invalid without a driver" do
      shift = Shift.new(shift_date: Date.today, shift_type: "am", driver: nil)
      expect(shift).not_to be_valid
      expect(shift.errors[:driver]).to include("must exist")
    end
  end

  describe ".shifts_by_date" do
    it "filters shifts by date" do
      shift1 = FactoryBot.create(:shift, shift_date: Date.today)
      FactoryBot.create(:shift, shift_date: Date.yesterday)

      expect(Shift.shifts_by_date(Shift.all, Date.today)).to contain_exactly(shift1)
    end
  end

  describe ".shifts_by_driver" do
    it "filters shifts by driver id" do
      driver1 = FactoryBot.create(:driver)
      driver2 = FactoryBot.create(:driver)
      shift1 = FactoryBot.create(:shift, driver: driver1)
      FactoryBot.create(:shift, driver: driver2)

      expect(Shift.shifts_by_driver(Shift.all, driver1.id)).to contain_exactly(shift1)
    end
  end

  describe ".today_driver_shifts" do
    it "returns today's shift for a driver" do
      driver = FactoryBot.create(:driver)
      shift = FactoryBot.create(:shift, driver: driver, shift_date: Time.zone.today)
      expect(Shift.today_driver_shifts(driver.id)).to eq(shift)
    end
  end
end
