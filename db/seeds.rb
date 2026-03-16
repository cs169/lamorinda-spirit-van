# frozen_string_literal: true

require "factory_bot_rails"
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

# crafting users (create at least one for each role)
if User.all.empty?
  FactoryBot.create(:user, :admin, email: "admin@example.com", password: "password")
  FactoryBot.create(:user, :dispatcher, email: "dispatcher@example.com", password: "password")
  FactoryBot.create(:user, :driver, email: "driver@example.com", password: "password")

  FactoryBot.create(:user, :driver, email: "alice@lamorinda.com", password: "abcde")
  FactoryBot.create(:user, :driver, email: "mike@lamorinda.com", password: "123456")
  FactoryBot.create(:user, :driver, email: "Emily@lamorinda.com", password: "emily")
end

# crafting drivers
10.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  FactoryBot.create(:driver,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

drivers = Driver.all.to_a

2.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  FactoryBot.create(:driver, :inactive,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

# crafting addresses
30.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  FactoryBot.create(:address, :lamorinda,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

addresses = Address.all.to_a

# crafting passengers
30.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  FactoryBot.create(:passenger,
    address: addresses.sample,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

passengers = Passenger.all.to_a

# crafting shifts
40.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)
  shift_date = Faker::Date.between(from: 60.days.ago, to: 60.days.from_now)
  pick_up_time = Time.zone.local(shift_date.year, shift_date.month, shift_date.day,
                                rand(8..18), [0, 15, 30, 45].sample)
  drop_off_time = pick_up_time + rand(1..8).hours

  FactoryBot.create(:shift,
    driver: drivers.sample,
    shift_date: shift_date,
    pick_up_time: pick_up_time.strftime("%-I:%M %p"),
    drop_off_time: drop_off_time.strftime("%-I:%M %p"),
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

shifts = Shift.all.to_a

# crafting rides
50.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)
  shift = shifts.sample
  date = shift.shift_date

  FactoryBot.create(:ride,
    passenger: passengers.sample,
    driver: shift.driver,
    start_address: addresses.sample,
    dest_address: addresses.sample,
    date: date,
    appointment_time: Time.zone.local(date.year, date.month, date.day, rand(8..18), [0, 15, 30, 45].sample),
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

rides = Ride.all.to_a

# crafting shift-templates
5.times do
  created_at = Faker::Time.between(from: 365.days.ago, to: Time.now)

  FactoryBot.create(:shift_template,
    driver: drivers.sample,
    created_at: created_at,
    updated_at: created_at + rand(1..30).days
  )
end

# crafting feedbacks
15.times do
  ride = rides.sample
  pick_up_time = Time.zone.local(ride.date.year, ride.date.month, ride.date.day,
                                 rand(8..18), [0, 15, 30, 45].sample)
  drop_off_time = pick_up_time + rand(1..8).hours

  FactoryBot.create(:feedback,
    ride: ride,
    pick_up_time: pick_up_time.strftime("%-I:%M %p"),
    drop_off_time: drop_off_time.strftime("%-I:%M %p"),
    created_at: drop_off_time + rand(1..18).hours,
    updated_at: drop_off_time + rand(1..10).days
  )
end
