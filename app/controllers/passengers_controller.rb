# frozen_string_literal: true

class PassengersController < ApplicationController
  before_action :set_passenger, only: %i[ show edit update destroy ]
  before_action -> { require_role("admin", "dispatcher") }

  # GET /passengers or /passengers.json
  def index
    @passengers = Passenger.includes(:address)
  end

  # GET /passengers/1 or /passengers/1.json
  def show
  end

  # GET /passengers/new
  def new
    @passenger = Passenger.new
    # since creating new passenger also have address,
    # this will also create new address record and associates it
    @passenger.build_address
  end

  # GET /passengers/1/edit
  def edit
  end

  # POST /passengers or /passengers.json
  def create
    @passenger = Passenger.new(passenger_params)

    respond_to do |format|
      if @passenger.save
        format.html { redirect_to passengers_path, notice: "Passenger created." }
        format.json { render :show, status: :created, location: @passenger }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /passengers/1 or /passengers/1.json
  def update
    @passenger = Passenger.find(params[:id])

    respond_to do |format|
      if @passenger.update(passenger_params)
        format.html { redirect_to edit_passenger_path(@passenger), notice: "Passenger updated." }
        format.json { render :show, status: :ok, location: @passenger }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @passenger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /passengers/1 or /passengers/1.json
  def destroy
    @passenger.destroy!

    respond_to do |format|
      format.html { redirect_to passengers_path, status: :see_other, notice: "Passenger deleted." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_passenger
    @passenger = Passenger.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def passenger_params
    params.require(:passenger).permit(:name, :phone, :alternative_phone, :birthday, :race, :hispanic, :wheelchair, :low_income, :disabled, :need_caregiver, :email, :notes, :date_registered, :audit,
                                      :lmv_member, :mail_updates, :rqsted_newsletter,
                                      address_attributes: [:street, :city, :zip_code])
  end
end
