# frozen_string_literal: true

require "csv"

def parse_address(destination_text)
  return nil if destination_text.blank?

  # Strict regex for the format: (Name) Street, City, CA Zip_code
  # Name, State and Zip are optional.
  regex = /
    ^
    (?:\((?<name>.*?)\)\s*)?
    (?<street>[^,]+),\s*
    (?<city>[^,]+)
    (?:
      \s*,\s*
      (?<state>CA|California)\s*
      (?<zip>\d{5})?
    )?
    \s*
    $
  /x

  match = destination_text.strip.match(regex)

  if match
    {
      name: match[:name]&.strip,
      street: match[:street].strip,
      city: match[:city].strip,
      zip_code: match[:zip]
    }
  else
    nil
  end
end

def convert_passenger_name(csv_name)
  # Convert "Last, First" to "First Last"
  return nil if csv_name.blank?

  parts = csv_name.strip.split(",").map(&:strip)
  return csv_name.strip if parts.length != 2

  "#{parts[1]} #{parts[0]}"
end

namespace :import do
  DRIVER_NAME_MAPPING = {
    "John S" => "John Raskin",
    "Anne" => "Anna Wah",
  }.freeze

  desc "Import shifts and rides from CSV file for a specific month"
  task :rides_month, [:month] => :environment do |task, args|
    # Validate month parameter
    month = args[:month]
    if month.blank?
      puts "ERROR: Please specify a month. Usage: rake import:rides_month[january]"
      exit 1
    end

    # Define source identifier and file path
    source = "#{month}_2024"
    
    # Try both full month name and abbreviated month name
    full_month_file = Rails.root.join("lib", "tasks", "rides_#{month.downcase}.csv")
    short_month_file = Rails.root.join("lib", "tasks", "rides_#{month.downcase[0..2]}.csv")
    
    file_path = if File.exist?(full_month_file)
      full_month_file
    elsif File.exist?(short_month_file)
      short_month_file
    else
      full_month_file # Use full name in error message
    end

    puts "Importing #{month.titleize} 2024 data..."
    puts "Source identifier: #{source}"
    puts "File path: #{file_path}"

    # Delete existing data for this month only
    puts "Deleting existing shifts for #{source} to prevent duplicates..."
    deleted_shifts = Shift.where(source: source).destroy_all
    puts "Deleted #{deleted_shifts.count} existing shifts"
    
    puts "Deleting existing rides for #{source} to prevent duplicates..."
    deleted_rides = Ride.where(source: source).destroy_all
    puts "Deleted #{deleted_rides.count} existing rides"

    unless File.exist?(file_path)
      puts "ERROR: Rides data file not found: #{file_path}"
      exit 1
    end

    puts "Importing from #{file_path}"

    # First pass: Create addresses
    puts "Creating destination addresses..."
    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      destinations = row["Destination"]&.split(/(?<=\d)\.\s*/) || []
      destinations.each do |destination_text|
        address_parts = parse_address(destination_text)
        if address_parts
          address = Address.find_or_create_by(street: address_parts[:street], city: address_parts[:city], zip_code: address_parts[:zip_code]) do |addr|
            addr.name = address_parts[:name]
            puts "Creating new address: #{address_parts.inspect}"
          end

          if address.name.blank? && address_parts[:name].present?
            address.update(name: address_parts[:name])
            puts "Updated address ID #{address.id} with name '#{address_parts[:name]}'"
          end
        else
          puts "ADDRESS PARSE ERROR: Please fix format for '#{destination_text.strip}'. Expected format: (Name) Street, City, CA Zip" unless destination_text.blank?
        end
      end
    end

    # Second pass: Create shifts
    puts "Creating shifts..."
    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      driver_entries = row["Driver"]&.strip&.split(",")&.map(&:strip)&.reject(&:empty?) || []
      van_entries = row["Van"]&.strip&.split(/[\s,]+/)&.map(&:strip)&.reject(&:empty?) || []

      next if driver_entries.empty?

      driver_entries.each_with_index do |driver_entry, index|
        match = driver_entry.match(/(.*?)\s*\((.*?)\)/)
        driver_name_from_csv = nil
        shift_type = nil

        if match
          driver_name_from_csv = match[1].strip
          shift_type = match[2].strip
        else
          driver_name_from_csv = driver_entry.strip
          shift_type = "general"
        end

        next if driver_name_from_csv.blank?

        db_driver_name = DRIVER_NAME_MAPPING[driver_name_from_csv] || driver_name_from_csv
        driver = Driver.find_by("name LIKE ?", "#{db_driver_name}%")

        unless driver
          puts "Driver not found for name: '#{driver_name_from_csv}' (mapped to: '#{db_driver_name}'). Skipping shift."
          next
        end

        van = van_entries[index]
        shift_date = row["Date"]

        shift = Shift.find_or_initialize_by(
          driver: driver,
          shift_date: shift_date,
          shift_type: shift_type,
          source: source
        )

        if shift.new_record?
          shift.van = van.present? ? van.to_i : nil
          shift.notes = row["Notes to Driver"]
          begin
            shift.save!
          rescue => e
            puts "Error creating shift for driver #{driver_name_from_csv} on date #{row['Date']}: #{e.message}"
          end
        end
      end
    end

    # Third pass: Create rides
    puts "Creating rides..."
    error_count = 0
    daily_ride_counters = {} # Track ride count per day for time calculation

    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      row_number = $.
      # Parse basic ride info
      passenger_csv_name = row["Passenger Name"]&.strip
      ride_count = row["Ride Count"]&.strip&.to_i || 1
      driver_entries = row["Driver"]&.strip&.split(",")&.map(&:strip)&.reject(&:empty?) || []
      van_entries = row["Van"]&.strip&.split(/[\s,]+/)&.map(&:strip)&.reject(&:empty?) || []

      # Parse the date and prepare for time calculation
      base_date = Date.parse(row["Date"]) rescue nil
      unless base_date
        puts "ERROR Row #{row_number}: Invalid date '#{row['Date']}'"
        error_count += 1
        next
      end

      # Initialize daily counter if not exists
      daily_ride_counters[base_date] ||= 0

      # Validate required fields
      if passenger_csv_name.blank?
        puts "ERROR Row #{row_number}: Missing passenger name"
        error_count += 1
        next
      end

      if driver_entries.empty?
        puts "ERROR Row #{row_number}: Missing driver information for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      if ride_count <= 0
        puts "ERROR Row #{row_number}: Invalid ride count '#{row['Ride Count']}' for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      # Find passenger
      passenger_db_name = convert_passenger_name(passenger_csv_name)
      passenger = Passenger.find_by(name: passenger_db_name)

      unless passenger
        puts "ERROR Row #{row_number}: Passenger not found for name '#{passenger_csv_name}' (converted to: '#{passenger_db_name}'). Please check passenger data."
        error_count += 1
        next
      end

      unless passenger.address
        puts "ERROR Row #{row_number}: Passenger '#{passenger.name}' has no home address. Cannot create rides."
        error_count += 1
        next
      end

      # Parse destinations
      destination_texts = row["Destination"]&.split(/(?<=\d)\.\s*/) || []
      destination_addresses = []

      if destination_texts.empty?
        puts "ERROR Row #{row_number}: No destinations found for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      destination_texts.each_with_index do |dest_text, idx|
        address_parts = parse_address(dest_text)
        if address_parts
          address = Address.find_by(
            street: address_parts[:street],
            city: address_parts[:city],
            zip_code: address_parts[:zip_code]
          )
          if address
            destination_addresses << address
          else
            puts "ERROR Row #{row_number}: Destination address not found for '#{dest_text.strip}'. Address should have been created in first pass."
            error_count += 1
          end
        else
          puts "ERROR Row #{row_number}: Could not parse destination '#{dest_text.strip}'"
          error_count += 1
        end
      end

      if destination_addresses.empty?
        puts "ERROR Row #{row_number}: No valid destination addresses found for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      # Get drivers
      drivers = []
      driver_entries.each_with_index do |driver_entry, idx|
        match = driver_entry.match(/(.*?)\s*\((.*?)\)/)
        driver_name_from_csv = match ? match[1].strip : driver_entry.strip

        db_driver_name = DRIVER_NAME_MAPPING[driver_name_from_csv] || driver_name_from_csv
        driver = Driver.find_by("name LIKE ?", "#{db_driver_name}%")

        if driver
          drivers << driver
        else
          puts "ERROR Row #{row_number}: Driver not found for '#{driver_name_from_csv}' (mapped to: '#{db_driver_name}'). Please check driver data."
          error_count += 1
        end
      end

      if drivers.empty?
        puts "ERROR Row #{row_number}: No valid drivers found for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      # Validate ride_count vs destinations
      max_expected_rides = destination_addresses.length + 1 # destinations + return home
      if ride_count > max_expected_rides + 2 # Allow some flexibility for extra rides
        puts "WARNING Row #{row_number}: Ride count #{ride_count} seems high for #{destination_addresses.length} destinations for passenger '#{passenger_csv_name}'"
      end

      # Create rides based on ride_count
      rides_to_create = []

      if ride_count == 1
        # Single one-way ride from home to first destination
        if destination_addresses.any?
          rides_to_create << {
            start_address: passenger.address,
            dest_address: destination_addresses.first,
            driver: drivers.first,
            van: van_entries.first&.to_i
          }
        end
      elsif ride_count == 2 && destination_addresses.length == 1
        # Round trip: home -> destination -> home
        rides_to_create << {
          start_address: passenger.address,
          dest_address: destination_addresses.first,
          driver: drivers.first,
          van: van_entries.first&.to_i
        }
        rides_to_create << {
          start_address: destination_addresses.first,
          dest_address: passenger.address,
          driver: drivers[1] || drivers.last,
          van: (van_entries[1] || van_entries.last)&.to_i
        }
      else
        # Multiple destinations: chain them together
        current_location = passenger.address

        destination_addresses.each_with_index do |dest_addr, idx|
          rides_to_create << {
            start_address: current_location,
            dest_address: dest_addr,
            driver: drivers[idx] || drivers.last,
            van: (van_entries[idx] || van_entries.last)&.to_i
          }
          current_location = dest_addr
        end

        # Add extra rides if ride_count > destinations + 1
        remaining_rides = ride_count - destination_addresses.length
        if remaining_rides > 0
          # First return home ride
          rides_to_create << {
            start_address: current_location,
            dest_address: passenger.address,
            driver: drivers.last,
            van: van_entries.last&.to_i
          }
          remaining_rides -= 1

          # Additional rides from last destination to home
          remaining_rides.times do
            rides_to_create << {
              start_address: destination_addresses.last,
              dest_address: passenger.address,
              driver: drivers.last,
              van: van_entries.last&.to_i
            }
          end
        end
      end

      # Calculate time once per CSV row: start at 10:00 AM + (daily_ride_counter * 10 minutes)
      ride_time = base_date.beginning_of_day + 10.hours + (daily_ride_counters[base_date] * 10.minutes)
      daily_ride_counters[base_date] += 1

      # Create the actual ride records with the same calculated time for all rides in this row
      created_rides = []
      rides_to_create.each_with_index do |ride_data, ride_idx|
        ride = Ride.create!(
          passenger: passenger,
          driver: ride_data[:driver],
          start_address_id: ride_data[:start_address]&.id,
          dest_address_id: ride_data[:dest_address]&.id,
          van: ride_data[:van],
          hours: row["Hours"]&.strip&.to_f,
          amount_paid: row["Amount Paid"]&.strip&.to_d,
          notes_to_driver: row["Notes to Driver"]&.strip,
          date_and_time: ride_time,
          status: row["Status"]&.strip,
          ride_type: "", # Empty
          notes: "", # Empty
          source: source
        )
        created_rides << ride
        puts "✓ Created ride #{ride_idx + 1}/#{rides_to_create.length} for #{passenger.name} at #{ride_time.strftime('%I:%M %p')}: #{ride_data[:start_address]&.street} -> #{ride_data[:dest_address]&.street}"
      rescue => e
        puts "ERROR Row #{row_number}: Failed to create ride #{ride_idx + 1} for #{passenger.name}: #{e.message}"
        error_count += 1
      end

      # Link rides with next_ride_id
      created_rides.each_with_index do |ride, idx|
        if idx < created_rides.length - 1
          begin
            ride.update!(next_ride_id: created_rides[idx + 1].id)
          rescue => e
            puts "ERROR Row #{row_number}: Failed to link ride #{idx + 1} to next ride for #{passenger.name}: #{e.message}"
            error_count += 1
          end
        end
      end
    end

    puts "\n" + "=" * 50
    if error_count > 0
      puts "Import for #{month.titleize} 2024 completed with #{error_count} errors. Please review and fix the CSV data."
    else
      puts "Import for #{month.titleize} 2024 completed successfully with no errors!"
    end
    
    # Show summary statistics
    total_rides = Ride.where(source: source).count
    total_shifts = Shift.where(source: source).count
    puts "Created #{total_rides} rides and #{total_shifts} shifts for #{source}"
    puts "=" * 50
  end

  desc "Show import status and usage examples"
  task :status => :environment do
    puts "\n" + "=" * 60
    puts "IMPORT STATUS"
    puts "=" * 60
    
    # Show what's been imported
    sources = Ride.distinct.pluck(:source).compact.sort
    if sources.any?
      puts "Imported months:"
      sources.each do |source|
        ride_count = Ride.where(source: source).count
        shift_count = Shift.where(source: source).count
        puts "  #{source}: #{ride_count} rides, #{shift_count} shifts"
      end
    else
      puts "No data imported yet."
    end
    
    puts "\n" + "=" * 60
    puts "USAGE EXAMPLES"
    puts "=" * 60
    puts "Import January data (looks for rides_january.csv or rides_jan.csv):"
    puts "  rake import:rides_month[january]"
    puts ""
    puts "Import February data (looks for rides_february.csv or rides_feb.csv):"
    puts "  rake import:rides_month[february]"
    puts ""
    puts "Re-import January (deletes only January data, keeps other months):"
    puts "  rake import:rides_month[january]"
    puts ""
    puts "Show this status:"
    puts "  rake import:status"
    puts "=" * 60
  end
end
