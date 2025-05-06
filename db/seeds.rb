# frozen_string_literal: true

require_relative "seed_data"

Driver.destroy_all

SeedData.drivers.each do |driver|
  Driver.create(driver)
end

if User.all.empty?
  User.create!(
    email: "admin@example.com",
    password: "password",
    role: "admin"
  )

  User.create!(
    email: "dispatcher@example.com",
    password: "password",
    role: "dispatcher"
  )

  User.create!(
    email: "driver@example.com",
    password: "password",
    role: "driver"
  )

  User.create!(
    email: "mike@lamorinda.com",
    password: "password",
    role: "driver"
  )

  User.create!(
    email: "sarah@lamorinda.com",
    password: "password",
    role: "driver"
  )

  User.create!(
    email: "Emily@lamorinda.com",
    password: "password",
    role: "driver"
  )
end


(Date.today.upto(Date.today + 60)).each do |day|
  drivers = Driver.all
  driver_id_am = day.mday % 6
  driver_id_pm = (day.mday + 1) % 5
  if day.wday in (1..5)
    if Shift.where(date: day).empty?
      Shift.create!(date: day, shift_type: "am", driver: drivers[driver_id_am])
      Shift.create!(date: day, shift_type: "pm", driver: drivers[driver_id_pm])
    end
  end
end
