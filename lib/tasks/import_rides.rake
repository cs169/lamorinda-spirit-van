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
    \.?
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

def normalize_name(name)
  return nil if name.blank?
  # Remove accents and normalize to ASCII
  name.strip
      .unicode_normalize(:nfd)
      .encode("ascii", fallback: ->(char) { char.unicode_normalize(:nfd).gsub(/[^\x00-\x7F]/, "") })
      .gsub(/\s+/, " ")
      .downcase
end

def find_or_create_smart_address(address_parts)
  street = address_parts[:street]
  city = address_parts[:city]
  zip_code = address_parts[:zip_code]
  name = address_parts[:name]
  normalized_name = normalize_name(name)

  address_description = "#{name.present? ? "(#{name}) " : ""}#{street}, #{city}#{zip_code.present? ? ", #{zip_code}" : ""}"

  # First, try to find an exact match including zip_code
  if zip_code.present?
    exact_match = Address.find_by(street: street, city: city, zip_code: zip_code)
    if exact_match
      puts "✓ Found exact match for #{address_description} -> Address ID #{exact_match.id}"
      # Update name if it was blank but we have a name now
      if exact_match.name.blank? && name.present?
        exact_match.update(name: name)
        puts "  └─ Enhanced existing address with name '#{name}'"
      end
      return exact_match
    else
      puts "⚬ No exact match found for #{address_description}, trying broader search..."
    end
  else
    puts "⚬ No zip code provided for #{address_description}, searching by street/city..."
  end

  # Second, try to find a match without zip_code (street + city only)
  potential_matches = Address.where(street: street, city: city)

  if potential_matches.any?
    puts "  ⚬ Found #{potential_matches.count} potential match(es) for #{street}, #{city}"

    # If we have a zip_code and there's a match without zip_code, update it
    if zip_code.present?
      match_without_zip = potential_matches.find { |addr| addr.zip_code.blank? }
      if match_without_zip
        match_without_zip.update(zip_code: zip_code)
        puts "  ✓ Enhanced existing address ID #{match_without_zip.id} with zip code '#{zip_code}'"
        if match_without_zip.name.blank? && name.present?
          match_without_zip.update(name: name)
          puts "  └─ Also added name '#{name}'"
        end
        return match_without_zip
      end
    end

    # If we have a name, try to find a match with similar normalized name
    if normalized_name.present?
      name_match = potential_matches.find do |addr|
        addr.name.present? && normalize_name(addr.name) == normalized_name
      end
      if name_match
        puts "  ✓ Found name match for #{address_description} -> Address ID #{name_match.id} (#{name_match.name})"
        # Update with zip_code if we have it and the match doesn't
        if zip_code.present? && name_match.zip_code.blank?
          name_match.update(zip_code: zip_code)
          puts "  └─ Enhanced with zip code '#{zip_code}'"
        end
        return name_match
      else
        puts "  ⚬ No name match found (looking for normalized '#{normalized_name}')"
      end
    end

    # Return the first match if no better match found
    first_match = potential_matches.first
    puts "  ✓ Using first available match -> Address ID #{first_match.id}"
    updates = []
    if zip_code.present? && first_match.zip_code.blank?
      first_match.update(zip_code: zip_code)
      updates << "zip code '#{zip_code}'"
    end
    if name.present? && first_match.name.blank?
      first_match.update(name: name)
      updates << "name '#{name}'"
    end
    if updates.any?
      puts "  └─ Enhanced with #{updates.join(' and ')}"
    end
    return first_match
  end

  # No matches found, create new address
  new_address = Address.create!(
    street: street,
    city: city,
    zip_code: zip_code,
    name: name
  )
  puts "✓ Created new address: #{address_description} -> Address ID #{new_address.id}"
  new_address
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
    "John S" => "John S.",
    "John S." => "John S.",
    "John R." => "John Raskin",
    "John R" => "John Raskin",
    "Anne" => "Anna Wah",
    "null driver" => "Unknown"
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

    # Check for CSV files in both /tmp and lib/tasks directories
    # Priority: /tmp (production) -> lib/tasks (development)
    tmp_full_month_file = File.join("/tmp", "rides_#{month.downcase}.csv")
    tmp_short_month_file = File.join("/tmp", "rides_#{month.downcase[0..2]}.csv")
    lib_full_month_file = Rails.root.join("lib", "tasks", "rides_#{month.downcase}.csv")
    lib_short_month_file = Rails.root.join("lib", "tasks", "rides_#{month.downcase[0..2]}.csv")

    file_path = if File.exist?(tmp_full_month_file)
      tmp_full_month_file
    elsif File.exist?(tmp_short_month_file)
      tmp_short_month_file
    elsif File.exist?(lib_full_month_file)
      lib_full_month_file
    elsif File.exist?(lib_short_month_file)
      lib_short_month_file
    else
      # Default to lib/tasks location for error message
      lib_full_month_file
    end

    puts "Importing #{month.titleize} 2024 data..."
    puts "Source identifier: #{source}"
    puts "File path: #{file_path}"

    # Delete existing data for this month only
    existing_shifts = Shift.where(source: source).count
    existing_rides = Ride.where(source: source).count

    if existing_shifts > 0 || existing_rides > 0
      puts "🧹 Cleaning up existing data for #{source} to prevent duplicates..."
      if existing_shifts > 0
        Shift.where(source: source).destroy_all
        puts "  ✓ Deleted #{existing_shifts} existing shifts"
      end
      if existing_rides > 0
        Ride.where(source: source).destroy_all
        puts "  ✓ Deleted #{existing_rides} existing rides"
      end
    else
      puts "✨ No existing data found for #{source} - starting fresh import"
    end

    unless File.exist?(file_path)
      puts "ERROR: Rides data file not found: #{file_path}"
      exit 1
    end

    puts "Importing from #{file_path}"

    puts "\n📍 Pass 1: Processing and creating destination addresses with smart matching..."
    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      destinations_string = row["Destination"]&.strip
      next if destinations_string.blank?

      # Split destinations by a period followed by whitespace.
      # This handles multiple addresses in the same field.
      destinations = destinations_string.scan(
        /
          (                           # Start capture group
            (?:\([^)]+\)\s*)?         # Optional (Name)
            [^.]+?,\s*[^.]+?        # Street, City
            (?:,\s*CA(?:\s+\d{5})?)?  # Optional state and zip
          )
          (?=\.|\z)                   # Must be followed by period or end of string
        /x
      ).flatten
      destinations.each do |destination_text|
        address_parts = parse_address(destination_text)
        if address_parts
          find_or_create_smart_address(address_parts)
        else
          puts "ADDRESS PARSE ERROR: Please fix format for '#{destination_text.strip}'. Expected format: (Name) Street, City, CA Zip" unless destination_text.blank?
        end
      end
    end

    puts "\n📋 Pass 2: Creating driver shifts..."
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

    puts "\n🚐 Pass 3: Creating rides and linking multi-stop journeys..."
    error_count = 0
    processed_rows = 0
    daily_ride_counters = {} # Track ride count per day for time calculation

    CSV.foreach(file_path, headers: true, liberal_parsing: true) do |row|
      row_number = $.
      processed_rows += 1

      # Show progress every 10 rows
      if processed_rows % 10 == 0
        puts "  📊 Processing row #{processed_rows}..."
      end

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
      destinations_string = row["Destination"]&.strip
      destination_addresses = []

      if destinations_string.blank?
        puts "ERROR Row #{row_number}: No destinations found for passenger '#{passenger_csv_name}'"
        error_count += 1
        next
      end

      # Split destinations by a period followed by whitespace.
      # This handles multiple addresses in the same field.
      destinations = destinations_string.scan(
        /
          (                           # Start capture group
            (?:\([^)]+\)\s*)?         # Optional (Name)
            [^.]+?,\s*[^.]+?        # Street, City
            (?:,\s*CA(?:\s+\d{5})?)?  # Optional state and zip
          )
          (?=\.|\z)                   # Must be followed by period or end of string
        /x
      ).flatten

      destinations.each_with_index do |dest_text, idx|
        address_parts = parse_address(dest_text)
        if address_parts
          address = find_or_create_smart_address(address_parts)
          destination_addresses << address
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

      ride_date = base_date
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
          date: row["Date"],
          status: row["Status"]&.strip,
          ride_type: "", # Empty
          notes: row["Notes/Date reserved"]&.strip.presence || row["Notes"]&.strip,
          source: source,
          wheelchair: passenger.wheelchair,
          disabled: passenger.disabled,
          need_caregiver: passenger.need_caregiver
        )
        created_rides << ride
        puts "✓ Created ride #{ride_idx + 1}/#{rides_to_create.length} for #{passenger.name} on #{ride_date.strftime('%m/%d/%Y')}: #{ride_data[:start_address]&.street} -> #{ride_data[:dest_address]&.street}"
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
    puts "IMPORT SUMMARY FOR #{month.titleize.upcase} 2024"
    puts "=" * 50

    if error_count > 0
      puts "❌ Import completed with #{error_count} errors. Please review and fix the CSV data."
    else
      puts "✅ Import completed successfully with no errors!"
    end

    # Show detailed statistics
    total_rides = Ride.where(source: source).count
    total_shifts = Shift.where(source: source).count
    total_addresses = Address.count
    unique_passengers = Ride.where(source: source).joins(:passenger).distinct.count(:passenger_id)
    unique_drivers = Ride.where(source: source).joins(:driver).distinct.count(:driver_id)

    puts "\nData Created:"
    puts "  🚐 #{total_rides} rides"
    puts "  👨‍💼 #{total_shifts} shifts"
    puts "  👥 #{unique_passengers} unique passengers served"
    puts "  🚗 #{unique_drivers} unique drivers assigned"
    puts "  📍 #{total_addresses} total addresses in system"

    # Show source breakdown
    puts "\nAll Import Sources:"
    sources_summary = Ride.group(:source).count
    sources_summary.each do |src, count|
      status = src == source ? " (just imported)" : ""
      puts "  #{src}: #{count} rides#{status}"
    end

    puts "=" * 50
  end

  desc "Show import status and usage examples"
  task status: :environment do
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
