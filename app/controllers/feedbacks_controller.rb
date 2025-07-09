# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :set_feedback, only: %i[ show edit update destroy ]

  # GET /feedbacks or /feedbacks.json
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1 or /feedbacks/1.json
  def show
    @current_date = @feedback.ride.date
    @passenger = @feedback.ride.passenger.name
    @rides = @feedback.ride.get_all_linked_rides
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
    @current_date = @feedback.ride.date
    @passenger = @feedback.ride.passenger.name
    @rides = @feedback.ride.get_all_linked_rides
  end

  # POST /feedbacks or /feedbacks.json
  def create
    @feedback = Feedback.new(feedback_params)

    respond_to do |format|
      if @feedback.save
        format.html { redirect_to @feedback, notice: "Feedback was successfully created." }
        format.json { render :show, status: :created, location: @feedback }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feedbacks/1 or /feedbacks/1.json
  def update
    if @feedback.update(feedback_params)
      driver = @feedback.ride.driver
      flash[:notice] = "Feedback for #{driver&.name || "Unknown"} was successfully updated."
      redirect_to edit_feedback_path(@feedback.ride.walk_to_root.feedback)
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1 or /feedbacks/1.json
  # No need to destroy feedbacks currently
  def destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def feedback_params
    params.require(:feedback).permit(:companion, :mobility, :note, :pick_up_time, :drop_off_time, :fare, :ride_id)
  end
end
