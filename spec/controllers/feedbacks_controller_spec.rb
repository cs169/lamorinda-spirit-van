# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeedbacksController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, :driver)
    sign_in @user

    @passenger = FactoryBot.create(:passenger)
    @driver = FactoryBot.create(:driver, email: @user.email)
    @ride = FactoryBot.create(:ride, driver: @driver, passenger: @passenger)
    @feedback = FactoryBot.create(:feedback, ride: @ride)
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    before do
      # Create a ride chain: @ride -> ride2 -> ride3
      @ride2 = FactoryBot.create(:ride, driver: @driver, passenger: @passenger, previous_ride: @ride)
      @ride3 = FactoryBot.create(:ride, driver: @driver, passenger: @passenger, previous_ride: @ride2)

      # Destroy any auto-created feedbacks for these rides
      @ride2.feedback&.destroy
      @ride3.feedback&.destroy
      @feedback2 = FactoryBot.create(:feedback, ride: @ride2)
      @feedback3 = FactoryBot.create(:feedback, ride: @ride3)
    end

    it "returns a successful response" do
      get :show, params: { id: @feedback.id }
      expect(response).to be_successful
    end

    it "assigns all rides in the chain to @rides" do
      get :show, params: { id: @feedback.id }
      expect(assigns(:rides)).to match_array([@ride, @ride2, @ride3])
    end

    it "assigns feedbacks for all rides in the chain" do
      get :show, params: { id: @feedback.id }
      chain_feedbacks = assigns(:rides).map(&:feedback)
      expect(chain_feedbacks).to match_array([@feedback, @feedback2, @feedback3])
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    before do
      @ride2 = FactoryBot.create(:ride, driver: @driver, passenger: @passenger, previous_ride: @ride)
      @ride3 = FactoryBot.create(:ride, driver: @driver, passenger: @passenger, previous_ride: @ride2)
      # Destroy any auto-created feedbacks for these rides
      @ride2.feedback&.destroy
      @ride3.feedback&.destroy

      @feedback2 = FactoryBot.create(:feedback, ride: @ride2)
      @feedback3 = FactoryBot.create(:feedback, ride: @ride3)
    end

    it "returns a successful response" do
      get :edit, params: { id: @feedback.id }
      expect(response).to be_successful
    end

    it "assigns all rides in the chain to @rides" do
      get :edit, params: { id: @feedback.id }
      expect(assigns(:rides)).to match_array([@ride, @ride2, @ride3])
    end

    it "assigns feedbacks for all rides in the chain" do
      get :edit, params: { id: @feedback.id }
      chain_feedbacks = assigns(:rides).map(&:feedback)
      expect(chain_feedbacks).to match_array([@feedback, @feedback2, @feedback3])
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new feedback and redirects to the feedback page" do
        expect {
          post :create, params: {
            feedback: {
              companion: "wife",
              mobility: "cane",
              note: "Smooth ride",
              pick_up_time: Time.zone.now,
              drop_off_time: Time.zone.now + 20.minutes,
              fare: 12.5,
              ride_id: @ride.id
            }
          }
        }.to change(Feedback, :count).by(1)

        expect(response).to redirect_to(assigns(:feedback))
        expect(flash[:notice]).to eq("Feedback was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "does not create feedback and re-renders the new template" do
        # Attempt to create feedback with missing required fields (e.g. ride_id)
        expect {
          post :create, params: {
            feedback: {
              companion: "",
              mobility: "",
              note: "",
              pick_up_time: "",
              drop_off_time: "",
              fare: "",
              ride_id: nil
            }
          }
        }.not_to change(Feedback, :count)

        # Expect response to render :new with unprocessable_entity status
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "updates the feedback and redirects to the chain feedback page" do
        # Simulate a ride chain, patch tail feedback, expect redirect back to edit view
        ride2 = FactoryBot.create(:ride, driver: @driver, passenger: @passenger, previous_ride: @ride)
        feedback2 = FactoryBot.create(:feedback, ride: ride2)
        patch :update, params: { id: feedback2.id, feedback: { note: "Updated note 2" } }
        feedback2.reload

        expect(feedback2.note).to eq("Updated note 2")
        expect(response).to redirect_to(edit_feedback_path(@ride))
        expect(response).to have_http_status(:see_other).or have_http_status(:found)
      end
    end

    context "with invalid parameters (HTML format)" do
      it "does not update the feedback and re-renders the edit template" do
        patch :update, params: {
          id: @feedback.id,
          feedback: { ride_id: nil }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end

    context "with invalid parameters (JSON format)" do
      it "returns JSON errors with status unprocessable_entity" do
        patch :update, params: {
          id: @feedback.id,
          feedback: { ride_id: nil }
        }, format: :json

        expect(response.content_type).to include("application/json")
        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json).to have_key("ride")
      end
    end

    context "when the driver of the ride was destroyed" do
      it "displays them as 'Unknown' and feedback can still be updated successfully" do
        @driver.destroy

        patch :update, params: {
          id: @feedback.id,
          feedback: { note: "deleted driver" }
        }

        @feedback.reload

        expect(@feedback.note).to eq("deleted driver")
        expect(@feedback.ride.driver).to be_nil
        expect(response).to redirect_to(edit_feedback_path(@feedback))
        expect(response).to have_http_status(:see_other).or have_http_status(:found)
      end
    end
  end
end
