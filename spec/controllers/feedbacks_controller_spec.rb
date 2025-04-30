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
    it "returns a successful response" do
      get :show, params: { id: @feedback.id }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: @feedback.id }
      expect(response).to be_successful
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
              pick_up_time: Time.now,
              drop_off_time: Time.now + 20.minutes,
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
      it "updates the feedback and redirects to driver today path with date param" do
        patch :update, params: {
          id: @feedback.id,
          feedback: {
            note: "Updated note"
          }
        }
        @feedback.reload
        expect(@feedback.note).to eq("Updated note")
        expected_date = @feedback.ride.date.to_s
        expect(response).to redirect_to(today_driver_path(@driver.id, date: expected_date))
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

    context "when feedback update succeeds but current_user is not a driver" do
      it "redirects to drivers_path" do
        other_user = FactoryBot.create(:user, :dispatcher, email: "not_a_driver@example.com")
        sign_in other_user

        patch :update, params: {
          id: @feedback.id,
          feedback: { note: "dispatcher/admin updated" }
        }

        expect(response).to redirect_to(drivers_path)
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the feedback and redirects to index" do
      expect {
        delete :destroy, params: { id: @feedback.id }
      }.to change(Feedback, :count).by(-1)

      expect(response).to redirect_to(feedbacks_path)
      expect(flash[:notice]).to eq("Feedback was successfully destroyed.")
    end
  end
end
