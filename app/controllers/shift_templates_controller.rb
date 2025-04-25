# frozen_string_literal: true

class ShiftTemplatesController < ApplicationController
  before_action :set_shift_template, only: %i[ show edit update destroy ]
  before_action -> { require_role("admin") }, only: [:new, :edit, :create, :update, :destroy]

  # GET /shift_templates/1 or /shift_templates/1.json
  def show
  end

  # GET /shift_templates/new
  def new
    @shift_template = ShiftTemplate.new(params.permit(:day_of_week))
    @drivers = Driver.order(:name)
  end

  # GET /shift_templates/1/edit
  def edit
    @drivers = Driver.order(:name)
  end

  # POST /shift_templates or /shift_templates.json
  def create
    @shift_template = ShiftTemplate.new(shift_template_params)

    respond_to do |format|
      if @shift_template.save
        format.html { redirect_to shifts_path, notice: "Shift template was successfully created." }
        format.json { render :show, status: :created, location: @shift_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shift_templates/1 or /shift_templates/1.json
  def update
    respond_to do |format|
      if @shift_template.update(shift_template_params)
        format.html { redirect_to shifts_path, notice: "Shift template was successfully updated." }
        format.json { render :show, status: :ok, location: @shift_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shift_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_templates/1 or /shift_templates/1.json
  def destroy
    @shift_template.destroy!

    respond_to do |format|
      format.html { redirect_to shift_templates_path, status: :see_other, notice: "Shift template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_shift_template
    @shift_template = ShiftTemplate.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def shift_template_params
    params.require(:shift_template).permit(:shift_type, :day_of_week, :driver_id)
  end
end
