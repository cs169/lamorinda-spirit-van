# frozen_string_literal: true

# Dev-only rake tasks for seeding fake ride data to simulate production volume.
# Usage:
#   rails dev:seed_rides        # create ~4600 fake rides
#   rails dev:unseed_rides      # remove all fake rides

namespace :dev do
  SEED_SOURCE = "dev_seed"

  STREETS = [
    "123 Moraga Way", "456 Glorietta Blvd", "789 Rheem Blvd", "321 Camino Pablo",
    "654 Happy Valley Rd", "987 Saint Marys Rd", "111 Diablo Rd", "222 Olympic Blvd",
    "333 Tice Valley Blvd", "444 Brookwood Rd"
  ].freeze

  CITIES = ["Moraga", "Orinda", "Lafayette", "Walnut Creek", "Danville"].freeze

  desc "Seed ~4600 fake rides for dev/test (tagged source=dev_seed)"
  task seed_rides: :environment do
    existing = Ride.where(source: SEED_SOURCE).count
    if existing > 0
      puts "#{existing} dev_seed rides already exist. Run rails dev:unseed_rides first."
      next
    end

    puts "Creating fake ride data..."

    # Reuse existing drivers/passengers if available, otherwise create some
    drivers = Driver.all.to_a
    if drivers.empty?
      5.times { |i| drivers << Driver.create!(name: "Dev Driver #{i + 1}", active: true) }
      puts "Created #{drivers.length} drivers."
    end

    passengers = Passenger.includes(:address).select { |p| p.address.present? }
    if passengers.empty?
      10.times do |i|
        addr = Address.create!(street: STREETS[i % STREETS.length], city: CITIES[i % CITIES.length])
        passengers << Passenger.create!(name: "Dev Passenger #{i + 1}", address: addr)
      end
      puts "Created #{passengers.length} passengers."
    end

    # Pool of addresses for destinations
    dest_addresses = Address.all.to_a
    if dest_addresses.length < 5
      10.times do |i|
        dest_addresses << Address.find_or_create_by!(
          street: STREETS[(i + 3) % STREETS.length],
          city:   CITIES[(i + 1) % CITIES.length]
        )
      end
    end

    total = 0
    target = 4600

    # Spread rides over ~3 years of past dates
    start_date = 3.years.ago.to_date
    end_date   = Date.today

    date_range = (start_date..end_date).to_a

    target.times do |i|
      passenger  = passengers[i % passengers.length]
      driver     = drivers[i % drivers.length]
      ride_date  = date_range[i % date_range.length]
      origin     = passenger.address
      dest       = dest_addresses[(i + 1) % dest_addresses.length]

      next if origin == dest

      Ride.create!(
        passenger:       passenger,
        driver:          driver,
        start_address:   origin,
        dest_address:    dest,
        date:            ride_date,
        van:             (i % 5) + 1,
        status:          "Completed",
        ride_type:       "One-way",
        wheelchair:      passenger.wheelchair,
        disabled:        passenger.disabled,
        need_caregiver:  passenger.need_caregiver,
        source:          SEED_SOURCE
      )
      total += 1
      print "." if total % 100 == 0
    end

    puts ""
    puts "Done. Created #{total} fake rides (source=#{SEED_SOURCE})."
    puts "Total rides in DB: #{Ride.count}"
  end

  desc "Remove all fake rides created by dev:seed_rides"
  task unseed_rides: :environment do
    count = Ride.where(source: SEED_SOURCE).count
    Ride.where(source: SEED_SOURCE).destroy_all
    puts "Removed #{count} dev_seed rides. Total rides remaining: #{Ride.count}"
  end
end
