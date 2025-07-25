# frozen_string_literal: true

class RidesController < ApplicationController
  before_action :set_ride, only: [ :show, :edit, :update, :destroy ]
  before_action -> { require_role("admin", "dispatcher") }, only: [:index, :new, :edit, :create, :update, :destroy]

  # Have only rides without previous rides (HEAD rides) be displayed
  # "Give me all rides whose id is not someone else's next_ride_id
  # — i.e., they're not the continuation of another ride."
  def index
    @rides = Ride.includes(:feedback, :driver, :passenger, :start_address, :dest_address, :next_ride)
                .where.not(id: Ride.select(:next_ride_id).where.not(next_ride_id: nil))
  end

  def show
    @all_rides = @ride.get_all_linked_rides
  end

  # new (GET Request, displays form)
  def new
    session[:return_to] = request.referer
    @ride = Ride.new(params.permit(:date, :driver_id))
    @ride.build_start_address
    @ride.build_dest_address

    # For driver dropdown list in creating / updating
    @drivers = Driver.order(:name)

    # For autofilling first stop's driver
    @ride.driver_id = params[:driver_id]

    # Load all passengers with their associations at once
    passengers_with_data = Passenger.includes(:address, :rides)

    gon.passengers = passengers_with_data.map { |p| {
      label: p.name, id: p.id, phone: p.phone, alt_phone: p.alternative_phone, wheelchair: p.wheelchair,
      disabled: p.disabled, need_caregiver: p.need_caregiver, low_income: p.low_income, lmv_member: p.lmv_member,
      notes: p.notes, ride_count: p.rides.length, # Use .length instead of .count for loaded association
      street: p.address&.street, city: p.address&.city
    } }
    gon.addresses = Address.all.map { |a| { name: a.name, street: a.street, city: a.city, phone: a.phone } }
    gon.drivers = @drivers.map { |d| { id: d.id, name: d.name } }
  end

  def create
    ride_attrs, addresses, stops_data = Ride.extract_attrs_from_params(ride_params)
    result_rides, success = Ride.build_linked_rides(ride_attrs, addresses, stops_data)

    if success
      @ride = result_rides[0]
      session[:return_to] ||= rides_path
      redirect_to session[:return_to], notice: "Ride was successfully created."
    else
      @ride = Ride.new(ride_attrs)
      @ride.valid?
      flash[:alert] = @ride.errors.full_messages.join
      Rails.logger.info("Ride creation failed: #{@ride.errors.full_messages}")
      render :new
    end
  end

  def edit
    # For driver dropdown list in creating / updating
    @ride = Ride.find(params[:id])
    @all_rides = @ride.get_all_linked_rides
    @drivers = Driver.order(:name)

    # Load all passengers with their associations at once
    passengers_with_data = Passenger.includes(:address, :rides)

    # Mapping data for autocomplete
    gon.passengers = passengers_with_data.map { |p| {
      label: p.name, id: p.id, phone: p.phone, alt_phone: p.alternative_phone, wheelchair: p.wheelchair,
      disabled: p.disabled, need_caregiver: p.need_caregiver, low_income: p.low_income, lmv_member: p.lmv_member,
      notes: p.notes, ride_count: p.rides.length, # Use .length instead of .count for loaded association
      street: p.address&.street, city: p.address&.city
    } }
    gon.addresses = Address.all.map { |a| { name: a.name, street: a.street, city: a.city, phone: a.phone } }
    gon.drivers = @drivers.map { |d| { id: d.id, name: d.name } }

    # Accessibility info is retrieved from the passenger
    @ride.wheelchair      = @ride.passenger&.wheelchair
    @ride.disabled        = @ride.passenger&.disabled
    @ride.need_caregiver  = @ride.passenger&.need_caregiver
  end

  def update
    @ride = Ride.find(params[:id])
    @drivers = Driver.order(:name)

    # Before destroying, copy feedback
    @feedback = @ride.feedback
    old_feedback_attrs = @feedback.attributes.except("id", "created_at", "updated_at", "ride_id") if @feedback

    ride_attrs, addresses, stops_data = Ride.extract_attrs_from_params(ride_params)

    # Destroy old ride chain
    all_rides = @ride.get_all_linked_rides
    ActiveRecord::Base.transaction do
      all_rides.reverse_each(&:destroy!)
    end

    # Rebuild new ride chain
    result_rides, success = Ride.build_linked_rides(ride_attrs, addresses, stops_data)

    if success
      @ride = result_rides[0]
      @ride.feedback.destroy if @ride.feedback && old_feedback_attrs
      @ride.create_feedback!(old_feedback_attrs) if old_feedback_attrs
      @ride.save!
      flash[:notice] = "Ride was successfully updated."
      redirect_to edit_ride_path(@ride)
    else
      @all_rides = @ride.get_all_linked_rides
      @ride = Ride.new(ride_attrs)
      @ride.valid?
      flash[:alert] = @ride.errors.full_messages.join
      Rails.logger.info("Ride update failed: #{@ride.errors.full_messages}")
      render :edit
    end
  end

  def destroy
    all_rides = @ride.get_all_linked_rides
    ActiveRecord::Base.transaction do
      all_rides.reverse_each(&:destroy!)
    end
    flash[:notice] = "Ride(s) were successfully removed."
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordNotDestroyed
    flash[:alert] = "Failed to remove the ride."
    redirect_to rides_url, status: :unprocessable_entity
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
      :status,
      :passenger_id,
      :driver_id,
      :notes,
      :notes_to_driver,
      :fare_type,
      :fare_amount,
      :appointment_time,
      :wheelchair,
      :disabled,
      :need_caregiver,
      :start_address_id,
      :dest_address_id,
      :ride_type,
      addresses_attributes: [:name, :street, :city, :phone],
      stops_attributes: [:driver_id, :van],
    )
  end
end
