# frozen_string_literal: true

class DriversController < ApplicationController
  before_action :set_driver, only: %i[ show edit update destroy today ]

  # GET /drivers or /drivers.json
  def index
    @drivers = Driver.all
    # @drivers = @drivers.filter_by_active(params[:active])
    # @drivers = @drivers.filter_by_name(params[:name])
  end

  # GET /drivers/:driver_id/shifts
  # Display all shifts for a certain driver
  def all_shifts
    @driver = Driver.find(params[:id])
    @shifts = @driver.shifts
  end

  def today
    @current_date = begin
                      Date.parse(params[:date])
                    rescue ArgumentError, TypeError
                      Time.zone.today
                    end

    @rides = @driver.rides.where(date: @current_date)
    @shift = @driver.shifts.where(shift_date: @current_date).first
  end

  # GET /drivers/1 or /drivers/1.json
  def show
  end

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
        format.html { redirect_to @driver, notice: "Driver was successfully created." }
        format.json { render :show, status: :created, location: @driver }
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
        format.html { redirect_to @driver, notice: "Driver was successfully updated." }
        format.json { render :show, status: :ok, location: @driver }
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
