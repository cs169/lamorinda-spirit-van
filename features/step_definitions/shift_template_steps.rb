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
  shifts_this_month = Shift.where("shift_date >= ? AND shift_date <= ?", Date.today.beginning_of_month, Date.today.end_of_month)
  expect(Shift.all.count).to eq(shifts_this_month.count)
end

Then("I remember how many shifts there are") do
  @shift_count = Shift.all.count
end

Then("there should be no new shifts") do
  expect(@shift_count).to equal(Shift.all.count)
end

Then(/^there should be ([0-9]*) shifts for (January|February|March|April|May|June|July|August|September|October|November|December)$/) do |count, month|
  date = Date.parse(month)
  shifts_this_month = Shift.where("shift_date >= ? AND shift_date <= ?", date.beginning_of_month, date.end_of_month)
  expect(shifts_this_month.count).to equal(count.to_i)
end

Given(/^([0-9]*) shifts exist for (January|February|March|April|May|June|July|August|September|October|November|December)$/) do |count, month|
  # dont put more shifts than there are days in the month
  date = Date.parse(month)
  (1..count.to_i).each do |i|
    FactoryBot.create(:shift, shift_date: date.beginning_of_month + i)
  end
end

Then("show all shifts") do
  puts Shift.all.map { |shift| "#{shift.shift_date}, #{shift.shift_type}" }
end
