# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import fake rides from CSV"
  task fake_rides: :environment do
    require Rails.root.join("app", "models", "ride")

    file_path = Rails.root.join("db", "fake_rides_data.csv")

    unless File.exist?(file_path)
      puts "CSV file not found at #{file_path}"
      exit
    end

    # Delete existing rides
    Ride.delete_all
    puts "Deleted all existing rides."

    puts "Importing fake rides from #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      puts "Row Data: #{row.to_h}"

      Ride.create!(
        date: Date.strptime(row["Date"], "%m/%d/%Y"),
        driver_id: row["driver_id"],
        van: row["Van"],
        passenger_id: row["passenger_id"],
        dest_address_id: row["dest_address_id"],
        start_address_id: row["start_address_id"],
        address_name: row["address_name"],
        notes_about_location: row["notes_about_location"],
        destination_type: row["destination_type"],
        wheelchair: row["wheelchair"].to_i == 1,
        low_income: row["low_income"].to_i == 1,
        disabled: row["disabled"].to_i == 1,
        need_caregiver: row["need_caregiver"].to_i == 1,
        notes: row["Notes"],
        hours: row["Hours"].to_f,
        amount_paid: row["Amount Paid"].to_f,
        notes_date_reserved: row["notes_date_reserved"],
        confirmed_with_passenger: row["Confirmed with passenger"],
        emailed_driver: row["emailed_driver"] == "sent",
      )
    end

    puts "Import complete!"
  end
end
