# frozen_string_literal: true

Given("the following driver exists:") do |table|
  table.hashes.each do |row|
    Driver.create!(name: row["name"])
  end
end

Given("the following shift exists:") do |table|
  table.hashes.each do |row|
    driver = Driver.find_by(name: row["driver"])
    shift_date =
      if row["shift_date"] == "Time.zone.today"
        Time.zone.today
      else
        Date.parse(row["shift_date"])
      end
    Shift.create!(
      driver: driver,
      shift_date: shift_date,
      shift_type: row["shift_type"]
    )
  end
end
