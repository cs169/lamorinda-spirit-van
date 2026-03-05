# frozen_string_literal: true

require "faker"

Feedback.destroy_all
Ride.destroy_all
ShiftTemplate.destroy_all
Shift.destroy_all
Driver.destroy_all
Passenger.destroy_all
Address.destroy_all

# setting constant seed for reproducibility
seed = 169
Faker::Config.random = Random.new(seed)
Faker::UniqueGenerator.clear

# creating users (at least one of each role)
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

# create tables using faker
10.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  Driver.create(
    name: Faker::Name.unique.name,
    phone: Faker::PhoneNumber.unique.phone_number,
    email: Faker::Internet.unique.email,
    active: true,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

2.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  Driver.create(
    name: Faker::Name.unique.name,
    phone: Faker::PhoneNumber.unique.phone_number,
    email: Faker::Internet.unique.email,
    active: false,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

30.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  Address.create(
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days,
    name: Faker::Address.community,
    phone: Faker::PhoneNumber.unique.phone_number,
    zip_code: Faker::Address.zip_code
  )
end

drivers = Driver.all.to_a
addresses = Address.all.to_a

30.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  Passenger.create(
    phone: Faker::PhoneNumber.unique.phone_number,
    alternative_phone: Faker::PhoneNumber.unique.phone_number,
    race: rand(1..5),
    email: Faker::Internet.unique.email,
    notes: Faker::Lorem.sentence,
    audit: Faker::Lorem.sentence,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days,
    address: addresses.sample,
    name: Faker::Name.unique.name,
    birthday: Faker::Date.birthday(min_age: 50, max_age: 100),
    hispanic: rand(0..1),
    date_registered: Faker::Time.between(from: 365.days.ago, to: Time.now),
    wheelchair: [true, false].sample,
    low_income: [true, false].sample,
    disabled: [true, false].sample,
    need_caregiver: [true, false].sample,
    mail_updates: Faker::Lorem.sentence,
    rqsted_newsletter: ["Yes", "No"].sample,
    lmv_member: [true, false].sample
  )
end

40.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)
  shift_date = Faker::Date.between(from: 60.days.ago, to: 60.days.from_now)
  pickup_time = Time.zone.local(shift_date.year, shift_date.month, shift_date.day, rand(8..18), [0, 15, 30, 45].sample)
  odometer_pre = rand(10000..50000).to_s

  Shift.create(
    shift_date: shift_date,
    shift_type: ["am", "pm", "Shopping", "CC", "LMV"].sample,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days,
    driver: drivers.sample,
    van: rand(1..10),
    pick_up_time: pickup_time.strftime("%-I:%M %p"),
    drop_off_time: (pickup_time + rand(1..8).hours).strftime("%-I:%M %p"),
    odometer_pre: odometer_pre,
    odometer_post: (odometer_pre.to_i + rand(10..100)).to_s,
    notes: Faker::Lorem.sentence,
    source: ["Phone", "Email"].sample,
    feedback_notes: Faker::Lorem.sentence
  )
end

passengers = Passenger.all.to_a
shifts = Shift.all.to_a

50.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)
  shift = shifts.sample
  date = shift.shift_date

  Ride.create(
    van: rand(1..10),
    hours: rand(0.5..3.0).round(2),
    amount_paid: rand(5.0..50.0).round(2),
    created_at: created_at,
    updated_at: created_at + rand(1..30).days,
    passenger: passengers.sample,
    driver: shift.driver,
    notes_to_driver: Faker::Lorem.sentence,
    start_address: addresses.sample,
    dest_address: addresses.sample,
    ride_type: ["One-way", "Round-trip"].sample,
    wheelchair: [true, false].sample,
    disabled: [true, false].sample,
    need_caregiver: [true, false].sample,
    next_ride_id: nil,
    date: date,
    status: ["Scheduled", "Requested", "Waitlisted", "Email sent", "Cancelled"].sample,
    notes: Faker::Lorem.sentence,
    source: ["Phone", "Email"].sample,
    fare_type: ["R", "LMV", "CC", "Shopping"].sample,
    appointment_time: Time.zone.local(date.year, date.month, date.day, rand(8..18), [0, 15, 30, 45].sample),
    fare_amount: rand(5.0..50.0).round(2)
  )
end

5.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  ShiftTemplate.create(
    shift_type: ["am", "pm", "Shopping", "CC", "LMV"].sample,
    day_of_week: rand(0..6),
    driver: drivers.sample,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

rides = Ride.all.to_a

5.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)
  pickup_time = Time.zone.local(2024, 1, 1, rand(8..18), [0, 15, 30, 45].sample)
  dropoff_time = pickup_time + rand(1..8).hours

  Feedback.create(
    companion: Faker::Name.unique.name,
    mobility: ["Independent", "Needs assistance", "Wheelchair user"].sample,
    note: Faker::Lorem.sentence,
    pick_up_time: pickup_time.strftime("%-I:%M %p"),
    drop_off_time: dropoff_time.strftime("%-I:%M %p"),
    fare: rand(5.0..50.0).round(2),
    created_at: created_at,
    updated_at: created_at + rand(1..30).days,
    ride: rides.sample
  )
end
