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

    puts "Importing fake rides from #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
        puts "Row Data: #{row.to_h}"
        # Create a new Ride record
        Ride.create!(
            day: row["Day"],
            date: Date.strptime(row["Date"], "%m/%d/%Y"),
            driver: row["Driver"],
            van: row["Van"],
            passenger_name_and_phone: row["Passenger Name and Phone"],
            passenger_address: row["Passenger Address"],
            destination: row["Destination"],
            notes_to_driver: row["Notes to Driver"],
            driver_initials: row["Driver Initials"],
            hours: row["Hours"].to_f,
            amount_paid: row["Amount Paid"].to_f,
            ride_count: row["Ride Count"].to_i,
            c: row["C"],
            notes_date_reserved: row["Notes/Date reserved"],
            confirmed_with_passenger: row["Confirmed w/passenger"],
            driver_email: row["Driver email"],
        )
        end

    puts "Import complete!"
  end
end
