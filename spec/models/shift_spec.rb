# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shift, type: :model do
  before(:each) do
    @driver = FactoryBot.create(:driver)
  end

  context "validations" do
    it "is valid with valid attributes" do
      shift = Shift.new(date: Time.zone.today, shift_type: "am", driver: @driver)
      expect(shift).to be_valid
    end

    it "is invalid without a date" do
      shift = Shift.new(date: nil, shift_type: "am", driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:date]).to include("can't be blank")
    end

    it "is invalid without a shift_type" do
      shift = Shift.new(date: Time.zone.today, shift_type: nil, driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:shift_type]).to include("can't be blank")
    end

    it "is invalid without a driver" do
      shift = Shift.new(date: Time.zone.today, shift_type: "am", driver: nil)
      expect(shift).not_to be_valid
      expect(shift.errors[:driver]).to include("must exist")
    end
  end

  describe ".shifts_by_date" do
    it "filters shifts by date" do
      shift1 = FactoryBot.create(:shift, date: Time.zone.today)
      FactoryBot.create(:shift, date: Date.yesterday)

      expect(Shift.shifts_by_date(Shift.all, Time.zone.today)).to contain_exactly(shift1)
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
      shift = FactoryBot.create(:shift, driver: driver, date: Time.zone.today)
      expect(Shift.today_driver_shifts(driver.id)).to eq(shift)
    end
  end


  describe ".fill_month" do
    it "adds shifts to a month from the given shift templates" do
      FactoryBot.create(:shift_template, day_of_week: 1)
      FactoryBot.create(:shift_template, day_of_week: 4)
      errors = Shift.fill_month(ShiftTemplate.all, Date.new(2025, 3, 15))
      expect(errors).to be_empty
      expect(Shift.count).to eq(9)
      shift_dates = Shift.all.map { |shift| shift.shift_date }
      expect(shift_dates).to eq([Date.new(2025, 3, 3),
                                 Date.new(2025, 3, 6),
                                 Date.new(2025, 3, 10),
                                 Date.new(2025, 3, 13),
                                 Date.new(2025, 3, 17),
                                 Date.new(2025, 3, 20),
                                 Date.new(2025, 3, 24),
                                 Date.new(2025, 3, 27),
                                 Date.new(2025, 3, 31)])
    end

    it "doesn't add shifts and returns errors list if something goes wrong" do
      FactoryBot.build(:shift_template, shift_type: nil).save(validate: false)
      errors = Shift.fill_month(ShiftTemplate.all, Date.new(2025, 3, 15))
      expect(errors).to_not be_empty
      expect(Shift.count).to eq(0)
    end
  end
end
