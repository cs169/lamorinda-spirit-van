# frozen_string_literal: true

class FeedbacksController < ApplicationController
  before_action :set_feedback, only: %i[ show edit update destroy ]

  # GET /feedbacks or /feedbacks.json
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1 or /feedbacks/1.json
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/1/edit
  def edit
    @current_date = @feedback.ride.date
    @passenger = @feedback.ride.passenger.name
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
    respond_to do |format|
      if @feedback.update(feedback_params)
        matched_driver = Driver.find_by("LOWER(email) = ?", current_user.email.downcase)
        if matched_driver
          redirect_to today_driver_path(matched_driver.id)
          return
        else
          redirect_to drivers_path
          return
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1 or /feedbacks/1.json
  def destroy
    @feedback.destroy!

    respond_to do |format|
      format.html { redirect_to feedbacks_path, status: :see_other, notice: "Feedback was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def feedback_params
    params.require(:feedback).permit(:companion, :mobility, :note, :pick_up_time, :drop_off_time, :fare)
  end
end
