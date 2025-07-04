# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import real passengers and their addresses from CSV"
  task real_passengers: :environment do
    require Rails.root.join("app", "models", "passenger")
    require Rails.root.join("app", "models", "address")

    file_path = Rails.root.join("lib", "tasks", "REAL_passengers_data.csv")

    unless File.exist?(file_path)
      puts "ERROR: Passenger data file not found: #{file_path}"
      exit 1
    end

    puts "Importing real passengers and addresses from #{file_path}..."

    # Use a transaction to ensure data consistency
    ActiveRecord::Base.transaction do
      CSV.foreach(file_path, headers: true) do |row|
        # First find or create the address
        address = Address.find_by(
          street: row["Address"],
          city: row["City"],
          zip_code: row["Zip"],
        )

        if address
          puts "Found existing address: #{address.full_address}"
        else
          puts "Creating new address for: #{row["Address"]}, #{row["City"]}, #{row["Zip"]}"
          address = Address.create!(
            street: row["Address"],
            city: row["City"],
            zip_code: row["Zip"],
          )
          puts "Created new address: #{address.full_address}"
        end

        # Parse birthday from timestamp format
        birthday = begin
          if row["Bday"].present?
            Date.parse(row["Bday"].split(" ").first)  # Take only the date part before the space
          end
        rescue Date::Error
          nil
        end

        # Create the passenger with the address
        passenger = Passenger.create!(
          name: row["Name"],
          address: address,
          phone: row["Phone"],
          alternative_phone: row["Alt Phone"],
          birthday: birthday,
          race: row["Race"].to_i,
          hispanic: row["Hispanic"] == "Yes",
          wheelchair: row["Wheelchair"] == "Yes",
          low_income: row["Low Income"] == "Yes",
          disabled: row["Disabled"] == "Yes",
          need_caregiver: row["Caregiver"] == "Yes",
          notes: row["Notes"].presence,
          email: row["Email"].presence,
          date_registered: row["Date Registered"].present? ? Time.zone.strptime(row["Date Registered"], "%Y-%m-%d") : nil,
          audit: row["Audit: Date, Status"],
          lmv_member: row["LMV Member"] == "Yes",
          mail_updates: row["Returned Mail Updates"].presence,
          rqsted_newsletter: row["Rqsted Newsletter by EMAIL"].presence
        )
        puts "Created passenger: #{passenger.name} with address: #{passenger.address.full_address}"
      end
    end

    puts "Import complete!"
  end
end
