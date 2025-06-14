# frozen_string_literal: true

require_relative "../lib/csv_encryption"

# Handle encrypted seed data
encrypted_seed_path = Rails.root.join("db", "seed_data.rb.enc")
fallback_seed_path = Rails.root.join("db", "seed_data.rb")

if File.exist?(encrypted_seed_path)
  puts "Using encrypted seed data..."
  begin
    decrypted_seed_path = CsvEncryption.decrypt_to_tempfile(encrypted_seed_path)
    load decrypted_seed_path
    File.delete(decrypted_seed_path) if File.exist?(decrypted_seed_path)
    puts "Loaded encrypted seed data successfully"
  rescue => e
    puts "ERROR: Failed to decrypt seed data: #{e.message}"
    puts "Make sure CSV_ENCRYPTION_KEY environment variable is set correctly"
    exit 1
  end
elsif File.exist?(fallback_seed_path)
  puts "Using unencrypted seed data (development mode)..."
  require_relative "seed_data"
else
  puts "ERROR: Neither encrypted nor unencrypted seed data file found"
  exit 1
end

Feedback.destroy_all
Ride.destroy_all
ShiftTemplate.destroy_all
Shift.destroy_all
Driver.destroy_all
Passenger.destroy_all
Address.destroy_all

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
