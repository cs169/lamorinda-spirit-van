# frozen_string_literal: true

class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]

  # GET /shifts or /shifts.json
  def index
    # @shifts = Shift.all
    @date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today
    @shifts = Shift.where(shift_date: @date.beginning_of_month..@date.end_of_month)
  end

  # GET /shifts/1 or /shifts/1.json
  def show
  end

  # GET /shifts/new
  def new
    @shift = Shift.new
  end

  # GET /shifts/1/edit
  def edit
  end

  # POST /shifts or /shifts.json
  def create
    # Check if there is a driver_id
    if params[:shift][:driver_id].blank?
      redirect_to new_shift_path, alert: "Driver is required to create a shift."
      return
    end

    # Find driver
    @driver = Driver.find_by(id: params[:shift][:driver_id])
    if @driver.nil?
      redirect_to new_shift_path, alert: "Driver not found."
      return
    end

    # Create shift
    @shift = @driver.shifts.build(shift_params)

    if @shift.save
      redirect_to @shift, notice: "Shift was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shifts/1 or /shifts/1.json
  def update
    respond_to do |format|
      if @shift.update(shift_params)
        format.html { redirect_to @shift, notice: "Shift was successfully updated." }
        format.json { render :show, status: :ok, location: @shift }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1 or /shifts/1.json
  def destroy
    @shift.destroy!

    respond_to do |format|
      format.html { redirect_to shifts_path, status: :see_other, notice: "Shift was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shift
    @shift = Shift.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def shift_params
    params.require(:shift).permit(:shift_date, :shift_type, :driver_id)
  end
end
