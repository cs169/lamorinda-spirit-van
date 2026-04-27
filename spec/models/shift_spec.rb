# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shift, type: :model do
  before(:each) do
    @driver = FactoryBot.create(:driver)
  end

  context "validations" do
    it "is valid with valid attributes" do
      shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver)
      expect(shift).to be_valid
    end

    it "is invalid without a shift_date" do
      shift = Shift.new(shift_date: nil, shift_type: "am", driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:shift_date]).to include("can't be blank")
    end

    it "is invalid without a shift_type" do
      shift = Shift.new(shift_date: Time.zone.today, shift_type: nil, driver: @driver)
      expect(shift).not_to be_valid
      expect(shift.errors[:shift_type]).to include("can't be blank")
    end

    it "is invalid without a driver" do
      shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: nil)
      expect(shift).not_to be_valid
      expect(shift.errors[:driver]).to include("must exist")
    end

    context "odometer fields" do
      it "is valid when both odometer fields are blank" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: nil, odometer_post: nil)
        expect(shift).to be_valid
      end

      it "is invalid with a non-numeric odometer_pre" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "abc", odometer_post: "100")
        expect(shift).not_to be_valid
        expect(shift.errors[:odometer_pre]).to include("is not a number")
      end

      it "is invalid with a non-numeric odometer_post" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "100", odometer_post: "xyz")
        expect(shift).not_to be_valid
        expect(shift.errors[:odometer_post]).to include("is not a number")
      end

      it "is invalid with a negative odometer_pre" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "-5", odometer_post: "100")
        expect(shift).not_to be_valid
        expect(shift.errors[:odometer_pre]).to include("must be greater than or equal to 0")
      end

      it "is invalid with a negative odometer_post" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "0", odometer_post: "-1")
        expect(shift).not_to be_valid
        expect(shift.errors[:odometer_post]).to include("must be greater than or equal to 0")
      end

      it "is invalid when odometer_post is less than odometer_pre" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "200", odometer_post: "150")
        expect(shift).not_to be_valid
        expect(shift.errors[:odometer_post])
          .to include("must be greater than or equal to the pre-trip odometer reading")
      end

      it "is valid when odometer_post equals odometer_pre" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "100", odometer_post: "100")
        expect(shift).to be_valid
      end

      it "is valid when odometer_post is greater than odometer_pre" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "100", odometer_post: "150")
        expect(shift).to be_valid
      end

      it "skips comparison when only one odometer value is present" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "100", odometer_post: nil)
        expect(shift).to be_valid
      end

      it "accepts decimal odometer values" do
        shift = Shift.new(shift_date: Time.zone.today, shift_type: "am", driver: @driver,
                          odometer_pre: "100.5", odometer_post: "150.25")
        expect(shift).to be_valid
      end
    end
  end

  describe "SHIFT_TYPES" do
    it "is a frozen array of the expected shift type values" do
      expect(Shift::SHIFT_TYPES).to eq(%w[AM PM Volunteer CC])
      expect(Shift::SHIFT_TYPES).to be_frozen
    end
  end

  describe ".shifts_by_date" do
    it "filters shifts by date" do
      shift1 = FactoryBot.create(:shift, shift_date: Time.zone.today)
      FactoryBot.create(:shift, shift_date: Time.zone.yesterday)

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
      shift = FactoryBot.create(:shift, driver: driver, shift_date: Time.zone.today)
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
