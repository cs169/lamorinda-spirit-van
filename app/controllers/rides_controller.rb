# frozen_string_literal: true

class RidesController < ApplicationController
  before_action :set_ride, only: [ :show, :edit, :update, :destroy ]

  def index
    @rides = Ride.all
  end

  def show
  end

  # new (GET Request, displays form)
  def new
    @ride = Ride.new
  end

  def create
    @ride = Ride.new(ride_params)
    if @ride.save
        redirect_to rides_path, notice: "Ride was successfully created."
    else
        render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ride.update(ride_params)
      flash[:notice] = "Ride was successfully updated."
      redirect_to edit_ride_path(@ride)
    else
      flash[:alert] = "There was an error updating the ride."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ride.destroy!
    redirect_to rides_url, notice: "Ride was successfully removed."
    rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = "Failed to remove the ride."
    redirect_to rides_url, status: :unprocessable_entity
  end

    def today
        driver_name_text = params[:driver_name_text].presence
        driver_name_select = params[:driver_name_select].presence
      
        @rides = Ride.driver_today_view(driver_name_text, driver_name_select)
        @drivers = Driver.all.pluck(:name).sort
    end

    def filter
        @rides = Ride.all
    end

    def filter_results
      filter_params = {
        'day': params['day'],
        'driver_name': params['driver_name'],
        'passenger_name_and_phone': params['passenger_name_and_phone'],
        'passenger_address': params['passenger_address'],
        'destination': params['destination'],
        'van': params['van'],
        'start_date': params['start_date'],
        'end_date': params['end_date'],
        'driver_email': params['driver_email'],
        'confirmed': params['confirmed'],
        'ride_count': params['ride_count'],
        'amount_paid': params['amount_paid'],
        'hours': params['hours'],
        'driver_initials': params['driver_initials']

      }

      @rides = Ride.filter_rides(filter_params)
      render :filter
    end

    private
  def set_ride
    @ride = Ride.find(params[:id])
  end

    def ride_params
        params.require(:ride).permit(:day, :date, :driver, :van, :passenger_name_and_phone, :passenger_address, :destination, :notes_to_driver, :hours, :amount_paid, :ride_count, :c, :notes_date_reserved, :confirmed_with_passenger, :driver_email)
    end

end
