# frozen_string_literal: true

class RidesController < ApplicationController
  before_action :set_ride, only: [ :show, :edit, :update, :destroy ]
  before_action -> { require_role("admin", "dispatcher") }, only: [:index, :new, :edit, :create, :update, :destroy]

  # Have only rides without previous rides (HEAD rides) be displayed
  # "Give me all rides whose id is not someone else's next_ride_id 
  # — i.e., they're not the continuation of another ride."
  def index
    @rides = Ride.where.not(id: Ride.select(:next_ride_id).where.not(next_ride_id: nil))
  end

  def show
  end

  # new (GET Request, displays form)
  def new
    session[:return_to] = request.referer
    @ride = Ride.new(params.permit(:date, :driver_id))
    @ride.build_start_address
    @ride.build_dest_address
    # For driver dropdown list in creating / updating
    @drivers = Driver.order(:name)
    gon.passengers = Passenger.all.map { |p| { label: p.name, id: p.id, phone: p.phone, notes: p.notes } }
    gon.addresses = Address.all.map { |a| { label: a.street, zip: a.zip, city: a.city } }
  end

  def create
    @ride = Ride.new(ride_params)
    if @ride.save
      session[:return_to] ||= rides_path
      redirect_to session[:return_to], notice: "Ride was successfully created."
    else
      flash[:alert] = @ride.errors.full_messages.join
      render :new
      # redirect_to new_ride_path
    end
  end

  def edit
    # For driver dropdown list in creating / updating
    @ride = Ride.find(params[:id])
    @drivers = Driver.order(:name)
  end

  def update
    @ride = Ride.find(params[:id])
    @drivers = Driver.order(:name)
    if @ride.update(ride_params)
      flash[:notice] = "Ride was successfully updated."
      redirect_to edit_ride_path(@ride)
      # else
      #   flash[:alert] = "There was an error updating the ride."
      #   render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ride.destroy!
    redirect_to rides_url, notice: "Ride was successfully removed."
  rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = "Failed to remove the ride."
    redirect_to rides_url, status: :unprocessable_entity
  end

  def filter
    @rides = Ride.all
  end

  def filter_results
    filter_params = {
      'day': params["day"],
      'driver_name': params["driver_name"],
      'passenger_name_and_phone': params["passenger_name_and_phone"],
      'passenger_address': params["passenger_address"],
      'destination': params["destination"],
      'van': params["van"],
      'start_date': params["start_date"],
      'end_date': params["end_date"],
      'driver_email': params["driver_email"],
      'confirmed': params["confirmed"],
      'ride_count': params["ride_count"],
      'amount_paid': params["amount_paid"],
      'hours': params["hours"],
      'driver_initials': params["driver_initials"]

    }

    @rides = Ride.filter_rides(filter_params)
    render :filter
  end

    private
  def set_ride
    @ride = Ride.find(params[:id])
  end

  def ride_params
    params.require(:ride).permit(
      :date,
      :van,
      :hours,
      :amount_paid,
      :notes_date_reserved,
      :confirmed_with_passenger,
      :passenger_id,
      :driver_id,
      :notes,
      :emailed_driver,
      :start_address_id,
      :dest_address_id,
      start_address_attributes: [:street, :city, :state, :zip],
      dest_address_attributes: [:street, :city, :state, :zip]
    )
  end
end
