# frozen_string_literal: true

class ShiftsController < ApplicationController
  before_action :set_shift, only: %i[ show edit update destroy ]
  before_action -> { require_role("admin") }, only: [:fill_from_template, :clear_month]
  before_action -> { require_role("admin", "dispatcher") }, only: [:new, :edit, :create, :destroy]

  # Currently the "capture_return_to" method is used for redirect from the shifts calendar to /drivers/id/today?date=XXX page
  before_action -> { capture_return_to(:return_to_drivers_today_from_shifts_index) }, only: :index

  # GET /shifts or /shifts.json
  def index
    # @shifts = Shift.all
    @date = params[:start_date] ? Time.zone.parse(params[:start_date]) : Time.zone.today
    @shifts = Shift.where(shift_date: @date.beginning_of_month..@date.end_of_month)
    @shift_templates = ShiftTemplate.all
  end

  # GET /shifts/1 or /shifts/1.json
  def show
    # driver can not visit /shifts/id page
    if current_user.role == "driver"
      redirect_to root_path, alert: "You are not authorized to view this page."
      return
    end

    @rides = Ride.includes(:passenger, :start_address, :dest_address, :next_ride)
    .where(driver_id: @shift.driver.id, date: @shift.shift_date)

    # Walk up to the root for each ride, collect unique roots
    @rides = @rides.map { |r| r.walk_to_root }.uniq

    # Use seconds_since_midnight b/c times in Rails are
    # TimeWithZone objects with an arbitrary date, sorting would not work correctly
    @rides = @rides.sort_by { |ride| ride.appointment_time ? ride.appointment_time.seconds_since_midnight : -1 }
  end

  # GET /shifts/new
  def new
    @shift = Shift.new
    @date = params[:date]
  end

  # GET /shifts/1/edit
  def edit
  end

  # GET /shifts/1/feedback
  def feedback
    @shift = Shift.find(params[:id])
  end

  # POST /shifts/fill_from_template
  def fill_from_template
    error_messages = Shift.fill_month(ShiftTemplate.all, Time.zone.parse(params[:date]))
    flash[:alert] = "Error with creating shifts from templates" unless error_messages.empty?
    redirect_to shifts_path(start_date: params[:date])
  end

  # POST /shifts/clear_month
  def clear_month
    Shift.clear_month(Time.zone.parse(params[:date]))
    redirect_to shifts_path(start_date: params[:date])
  end

  # POST /shifts or /shifts.json
  def create
    if params[:shift][:driver_id].blank?
      redirect_to new_shift_path, alert: "Driver is required to create a shift."
      return
    end

    @driver = Driver.find_by(id: params[:shift][:driver_id])
    if @driver.nil?
      redirect_to new_shift_path, alert: "Driver not found."
      return
    end

    @shift = @driver.shifts.build(shift_params)

    if @shift.save
      redirect_to shifts_path, notice: "Shift was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shifts/1 or /shifts/1.json
  def update
    if params[:commit_type] == "feedback"
      # Allow driver to submit feedback
      if @shift.update(shift_params)
        redirect_to today_driver_path(id: @shift.driver_id, date: @shift.shift_date),
          notice: "Shift feedback was successfully saved."
      else
        render :feedback, status: :unprocessable_entity
      end
      return
    end

    # For non-feedback updates, still require admin/dispatcher
    require_role("admin", "dispatcher")
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
      format.html { redirect_to shifts_path, status: :see_other, notice: "Shift was successfully deleted." }
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
    params.require(:shift).permit(:shift_date, :shift_type, :driver_id, :van, :notes,
    :feedback_notes, :pick_up_time, :drop_off_time, :odometer_pre, :odometer_post,
    :second_pick_up_time, :second_drop_off_time)
  end
end
