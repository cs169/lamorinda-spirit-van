# frozen_string_literal: true

Feedback.destroy_all
Ride.destroy_all
ShiftTemplate.destroy_all
Shift.destroy_all
Driver.destroy_all
Passenger.destroy_all
Address.destroy_all

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
