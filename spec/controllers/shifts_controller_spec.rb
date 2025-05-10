# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShiftsController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, :dispatcher)
    sign_in @user

    @driver = FactoryBot.create(:driver)
    @shift = FactoryBot.create(:shift, driver: @driver)
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    context "when current user is a driver" do
      it "redirects driver to root_path with alert" do
        sign_out @user
        driver_user = FactoryBot.create(:user, :driver)
        sign_in driver_user

        get :show, params: { id: @shift.id }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to view this page.")
      end
    end

    context "when current user is a dispatcher or admin" do
      it "assigns rides for the shift date" do
        ride1 = FactoryBot.create(:ride, date_and_time: @shift.shift_date.to_datetime.change(hour: 9))
        ride2 = FactoryBot.create(:ride, date_and_time: @shift.shift_date.to_datetime.change(hour: 13))
        ride3 = FactoryBot.create(:ride, date_and_time: (@shift.shift_date + 1.day).to_datetime.change(hour: 9))

        get :show, params: { id: @shift.id }

        expect(assigns(:rides)).to include(ride1, ride2)
        expect(assigns(:rides)).not_to include(ride3)
        expect(response).to be_successful
      end
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new shift and redirects to the shift page" do
        expect {
          post :create, params: { shift: { shift_date: Date.today, shift_type: "evening", driver_id: @driver.id } }
        }.to change(Shift, :count).by(1)

        expect(response).to redirect_to(shifts_path)
      end
    end

    context "with empty shift_type" do
      it "does not create a shift and re-renders the new template" do
        expect {
          post :create, params: { shift: { shift_date: Date.today, shift_type: "", driver_id: @driver.id } }
        }.not_to change(Shift, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end

    context "with missing driver_id" do
      it "does not create a shift and redirects to new_shift_path with an alert" do
        expect {
          post :create, params: { shift: { shift_date: Date.today, shift_type: "evening", driver_id: nil } }
        }.not_to change(Shift, :count)

        expect(response).to redirect_to(new_shift_path)
        expect(flash[:alert]).to eq("Driver is required to create a shift.")
      end
    end

    context "with invalid driver_id" do
      it "does not create a shift and redirects to new_shift_path with an alert" do
        expect {
          post :create, params: { shift: { shift_date: Date.today, shift_type: "evening", driver_id: 9999 } }
        }.not_to change(Shift, :count)

        expect(response).to redirect_to(new_shift_path)
        expect(flash[:alert]).to eq("Driver not found.")
      end
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: @shift.id }
      expect(response).to be_successful
    end
  end

  describe "GET #feedback" do
    it "returns a successful response" do
      get :feedback, params: { id: @shift.id }
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "when submitting feedback as driver" do
      before do
        sign_out @user
        @driver_user = FactoryBot.create(:user, :driver)
        sign_in @driver_user
      end

      it "updates feedback fields and redirects to driver's today page" do
        patch :update, params: {
          id: @shift.id,
          shift: {
            van: 101,
            pick_up_time: "08:00",
            drop_off_time: "10:00",
            odometer_pre: "12345",
            odometer_post: "12400"
          },
          commit_type: "feedback"
        }

        @shift.reload
        expect(@shift.van).to eq(101)
        expect(@shift.pick_up_time).to eq("08:00")
        expect(@shift.drop_off_time).to eq("10:00")
        expect(@shift.odometer_pre).to eq("12345")
        expect(@shift.odometer_post).to eq("12400")
        expect(response).to redirect_to(today_driver_path(id: @shift.driver_id))
      end
    end

    context "when driver tries to modify non-feedback fields" do
      before do
        sign_out @user
        @driver_user = FactoryBot.create(:user, :driver)
        sign_in @driver_user
      end

      it "does not allow driver to modify shift_type or driver_id" do
        old_shift_type = @shift.shift_type
        old_driver_id = @shift.driver_id

        patch :update, params: {
          id: @shift.id,
          shift: {
            shift_type: "illegal_change",
            driver_id: 9999
          },
          commit_type: "feedback"
        }

        @shift.reload

        expect(@shift.shift_type).to eq(old_shift_type)
        expect(@shift.driver_id).to eq(old_driver_id)
      end
    end

    context "when dispatcher fails to update shift" do
      it "re-renders the edit template with unprocessable_entity status" do
        patch :update, params: { id: @shift.id, shift: { shift_date: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end

    context "when dispatcher successfully updates shift with JSON format" do
      it "returns status OK and correct content type" do
        patch :update, params: {
          id: @shift.id,
          shift: { shift_type: "night" }
        }, as: :json

        @shift.reload
        expect(@shift.shift_type).to eq("night")
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the shift and redirects to the shifts index" do
      expect {
        delete :destroy, params: { id: @shift.id }
      }.to change(Shift, :count).by(-1)

      expect(response).to redirect_to(shifts_path)
    end
  end
end
