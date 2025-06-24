# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import drivers from lib/tasks/drivers.csv"
  task drivers: :environment do
    file_path = Rails.root.join("lib", "tasks", "drivers.csv")
    unless File.exist?(file_path)
      puts "ERROR: Driver data file not found: #{file_path}"
      exit 1
    end

    puts "Importing drivers from #{file_path}..."

    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      driver_attributes = {
        name: row["name"],
        email: row["email"],
        phone: row["phone"],
        active: row["active"] == "true"
      }

      driver = Driver.find_or_initialize_by(name: driver_attributes[:name])
      driver.update(driver_attributes)

      if driver.persisted?
        puts "Updating driver: #{driver.name}"
      else
        puts "Creating new driver: #{driver.name}"
      end

      unless driver.save
        puts "ERROR: Could not save driver #{driver.name}. Errors: #{driver.errors.full_messages.join(', ')}"
      end
    end

    puts "Driver import complete."
  end
end
