# frozen_string_literal: true

class Ride < ApplicationRecord
  validates :day, :date, :passenger_name_and_phone, presence: true

  def self.today_rides(rides)
    rides.where(date: Time.zone.today)
  end

  def self.rides_by_driver(rides, driver_name)
    rides = rides.where("driver LIKE ?", "%#{driver_name}%") if driver_name.present?
    rides
  end

  # Filter rides by driver_name_text and driver_name_select
  # if driver_name_text and driver_name_select are present, return rides that match either driver_name_text OR driver_name_select
  # if driver_name_text is present, return rides that match driver_name_text
  # if driver_name_select is present, return rides that match driver_name_select
  # if neither driver_name_text nor driver_name_select are present, return all rides

  def self.driver_today_view(driver_name_text = nil, driver_name_select = nil)
    rides = today_rides(Ride.all)
    if driver_name_text.present? && driver_name_select.present?
      rides_text = rides_by_driver(rides, driver_name_text)
      rides_select = rides_by_driver(rides, driver_name_select)
      rides = rides_text.or(rides_select).distinct
    elsif driver_name_text.present?
      rides = rides_by_driver(rides, driver_name_text)
    elsif driver_name_select.present?
      rides = rides_by_driver(rides, driver_name_select)
    end
    rides
  end

  def self.filter_rides(filter_params)
    puts filter_params
    rides = Ride.all

    if filter_params[:day].present?
      day = filter_params[:day]
      rides = rides.where("LOWER(day) LIKE ?", "%#{day.downcase}%")
      puts rides
    end

    if filter_params[:driver_name].present?
      driver_name = filter_params[:driver_name]
      rides = rides.where("LOWER(driver) LIKE ?", "%#{driver_name.downcase}%")
      puts rides
    end
    
    if filter_params[:passenger_name_and_phone].present?
      passenger_name_and_phone = filter_params[:passenger_name_and_phone]
      rides = rides.where("LOWER(passenger_name_and_phone) LIKE ?", "%#{passenger_name_and_phone.downcase}%")
      puts rides
    end
    
    if filter_params[:passenger_address].present?
      passenger_address = filter_params[:passenger_address]
      rides = rides.where("LOWER(passenger_address) LIKE ?", "%#{passenger_address.downcase}%")
      puts rides
    end

    if filter_params[:destination].present?
      destination = filter_params[:destination]
      rides = rides.where("LOWER(destination) LIKE ?", "%#{destination.downcase}%")
      puts rides
    end


    if filter_params[:start_date].present?
      date_start = Date.parse(filter_params[:start_date])
      rides = rides.where("date >= ?", date_start) if date_start
      puts rides
    end

    if filter_params[:end_date].present?
      date_end = Date.parse(filter_params[:end_date])
    else
      date_end = Date.today
    end
    rides = rides.where("date <= ?", date_end) if date_end
    puts rides



    if filter_params[:driver_email].present?
      driver_email = filter_params[:driver_email]
      rides = rides.where("LOWER(driver_email) LIKE ?", "%#{driver_email.downcase}%")
      puts rides
    end

    if filter_params[:driver_initials].present?
      driver_initials = filter_params[:driver_initials]
      rides = rides.where("LOWER(driver_initials) LIKE ?", "%#{driver_initials.downcase}%")
      puts rides
    end

    if filter_params[:confirmed].present?
      confirmed = filter_params[:confirmed]
      rides = rides.where("LOWER(confirmed_with_passenger) LIKE ?", "%#{confirmed.downcase}%")
      puts rides
    end

    if filter_params[:ride_count].present?
      ride_count = filter_params[:ride_count]
      rides = rides.where("ride_count = ?", ride_count)
      puts rides
    end

    if filter_params[:amount_paid].present?
      amount_paid = filter_params[:amount_paid]
      rides = rides.where("amount_paid = ?", amount_paid)
      puts rides
    end

    if filter_params[:hours].present?
      hours = filter_params[:hours]
      rides = rides.where("hours = ?", hours)
      puts rides
    end


    rides = rides.where(van: filter_params[:van].presence) if filter_params[:van].present?
    
    


    
    
    rides
  end
end
