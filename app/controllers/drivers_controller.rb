# frozen_string_literal: true

class DriversController < ApplicationController
  before_action :set_driver, only: %i[ edit update destroy today ]
  before_action -> { require_role("admin", "dispatcher") }, only: [:new, :edit, :create, :update, :destroy]

  # Currently the "capture_return_to" method is used for redirect from the drivers index page to /drivers/id/today?date=XXX page
  before_action -> { capture_return_to(:return_to_drivers_today_from_drivers_index) }, only: :index

  # GET /drivers or /drivers.json
  def index
    dont_jump = params[:dont_jump]
    unless dont_jump
      if current_user.role == "driver"
        matched_driver = Driver.find_by("LOWER(email) = ?", current_user.email.downcase)
        if matched_driver
          redirect_to today_driver_path(matched_driver.id)
          return
        else
          flash.now[:alert] = "No matching driver profile found for your account."
        end
      end
    end

    @drivers = Driver.all
    # @drivers = @drivers.filter_by_active(params[:active])
    # @drivers = @drivers.filter_by_name(params[:name])
  end

  # GET /drivers/:driver_id/shifts
  # Display all upcoming shifts for a certain driver
  def upcoming_shifts
    @current_date = begin
                  Date.parse(params[:date])
                rescue ArgumentError, TypeError
                  Time.zone.today
                end

    month_start = @current_date.beginning_of_month
    month_end = @current_date.end_of_month

    @driver = Driver.find(params[:id])
    @return_url = params[:return_url] || request.referer
    @shifts = @driver.shifts.where(shift_date: month_start..month_end)
                    .where("shift_date >= ?", Date.today)
                    .order(:shift_date)
  end

  def today
    @current_date = begin
                      Date.parse(params[:date])
                    rescue ArgumentError, TypeError
                      Time.zone.today
                    end

    @rides = @driver.rides.includes(:passenger, :feedback, :start_address, :dest_address, :next_ride)
    .where(date_and_time: @current_date.all_day)
    .where.not(id: Ride.select(:next_ride_id).where.not(next_ride_id: nil))
    @shift = @driver.shifts.where(shift_date: @current_date).first

    # Clear return_to_driver parameter after redirect from drivers index page to /drivers/id/today?date=XXX page
    clear_return_to(:return_to_drivers_today_from_drivers_index)

    clear_return_to(:return_to_drivers_today_from_drivers_index)
  end

  # NOTE: We deliberately disabled the `show` action.
  # If you need to add it, please check this commit and modify some related code.
  # Currently the /drivers shows all drivers.
  # Invalid URL: /drivers/:id

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  # GET /drivers/1/edit
  def edit
  end

  # POST /drivers or /drivers.json
  def create
    @driver = Driver.new(driver_params)

    respond_to do |format|
      if @driver.save
        format.html { redirect_to drivers_path, notice: "Driver was successfully created." }
        format.json { render json: @driver, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drivers/1 or /drivers/1.json
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        format.html { redirect_to drivers_path, notice: "Driver was successfully updated." }
        format.json { render json: @driver, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1 or /drivers/1.json
  def destroy
    @driver.destroy!
    respond_to do |format|
      format.html { redirect_to drivers_path, status: :see_other, notice: "Driver was successfully destroyed." }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotDestroyed
    respond_to do |format|
      format.html { redirect_to drivers_path, alert: "Failed to remove the driver.", status: :unprocessable_entity }
      format.json { render json: { error: "Failed to remove the driver." }, status: :unprocessable_entity }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_driver
    @driver = Driver.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def driver_params
    params.require(:driver).permit(:name, :phone, :email, :shifts, :active)
  end
end
