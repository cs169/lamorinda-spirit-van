# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import fake passengers from CSV"
  task fake_passengers: :environment do
    require Rails.root.join("app", "models", "passenger")

    file_path = Rails.root.join("db", "fake_passengers.csv")

    unless File.exist?(file_path)
      puts "CSV file not found at #{file_path}"
      exit
    end

    puts "Importing fake passengers from #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      puts "Row Data: #{row.to_h}"
      Passenger.create!(
          name: row["Name"],
          address_id: row["address_id"],
          phone: row["Phone"],
          alternative_phone: row["Alternative Phone"],
          birthday: Date.parse(row["Birthday"]),
          race: row["Race"].to_i,
          hispanic: row["Hispanic"] == "Yes",
          email: row["Email"].presence,
          notes: row["Notes"].presence,
          date_registered: Date.strptime(row["Date Registered"], "%m/%d/%Y"),
          audit: row["Audit"]
        )
    end

    puts "Import complete!"
  end
end
