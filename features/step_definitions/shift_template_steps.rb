# frozen_string_literal: true

Then(/^there should be "([^"]*)" shifts for driver "([^"]*)" for each ([^ ]*) of this month$/) do |shift_type, driver_name, day_of_week|
  shifts = Driver.where(name: driver_name).first.shifts.where(shift_type: shift_type)
  day_of_week = Date.parse(day_of_week).wday

  (Date.today.beginning_of_month..Date.today.end_of_month).each do |date|
    if date.wday == day_of_week
      shift = shifts.where(shift_date: date)
      expect(shift).not_to be_nil
    end
  end
end

Then("there should be no shifts any other month") do
  shifts_this_month = Shift.where("shift_date >= ? AND shift_date <= ", Date.today.beginning_of_month, Date.today.end_of_month)
  expect(Shift.all.count).to equal(shifts_this_month.count)
end
