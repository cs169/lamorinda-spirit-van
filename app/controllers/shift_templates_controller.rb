# frozen_string_literal: true

class ShiftTemplatesController < ApplicationController
  before_action :set_shift_template, only: %i[ edit update destroy ]
  before_action -> { require_role("admin") }

  # GET /shift_templates/new
  def new
    @shift_template = ShiftTemplate.new(params.permit(:day_of_week))
    set_drivers
    set_start_date_presence
  end

  # GET /shift_templates/1/edit
  def edit
    set_shift_template
    set_drivers
    set_start_date_presence
  end

  # POST /shift_templates or /shift_templates.json
  def create
    @shift_template = ShiftTemplate.new(shift_template_params)
    set_start_date
    respond_to do |format|
      if @shift_template.save
        format.html { redirect_to shifts_path(start_date: @start_date), notice: "Shift template was successfully created." }
        format.json { render :show, status: :created, location: @shift_template }
      else
        set_drivers
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shift_templates/1 or /shift_templates/1.json
  def update
    set_start_date
    respond_to do |format|
      if @shift_template.update(shift_template_params)
        format.html { redirect_to shifts_path(start_date: @start_date), notice: "Shift template was successfully updated." }
        format.json { render :show, status: :ok, location: @shift_template }
      else
        set_drivers
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_templates/1 or /shift_templates/1.json
  def destroy
    @shift_template.destroy!

    respond_to do |format|
      format.html { redirect_to shifts_path, status: :see_other, notice: "Shift template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  def set_start_date
    @start_date = params[:start_date]
  end

  def set_start_date_presence
    @start_date = params[:start_date].presence || Time.zone.today.to_s
  end

  def set_drivers
    @drivers = Driver.order(:name)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_shift_template
    @shift_template = ShiftTemplate.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def shift_template_params
    params.require(:shift_template).permit(:shift_type, :day_of_week, :driver_id)
  end
end
