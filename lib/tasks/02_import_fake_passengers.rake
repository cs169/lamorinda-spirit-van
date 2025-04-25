# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import fake passengers from CSV"
  task fake_passengers: :environment do
    require Rails.root.join("app", "models", "passenger")

    file_path = Rails.root.join("db", "fake_passengers_data.csv")

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
          wheelchair: row["wheelchair"].to_i == 1,
          low_income: row["low_income"].to_i == 1,
          disabled: row["disabled"].to_i == 1,
          need_caregiver: row["need_caregiver"].to_i == 1,
          notes: row["Notes"].presence,
          email: row["Email"].presence,
          date_registered: Date.strptime(row["Date Registered"], "%Y-%m-%d"),
          audit: row["Audit"]
        )
    end

    puts "Import complete!"
  end
end
