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
    it "returns a successful response" do
      get :show, params: { id: @shift.id }
      expect(response).to be_successful
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
          post :create, params: { shift: { date: Date.today, shift_type: "evening", driver_id: @driver.id } }
        }.to change(Shift, :count).by(1)

        expect(response).to redirect_to(shifts_path)
      end
    end

    context "with empty shift_type" do
      it "does not create a shift and re-renders the new template" do
        expect {
          post :create, params: { shift: { date: Date.today, shift_type: "", driver_id: @driver.id } }
        }.not_to change(Shift, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end

    context "with missing driver_id" do
      it "does not create a shift and redirects to new_shift_path with an alert" do
        expect {
          post :create, params: { shift: { date: Date.today, shift_type: "evening", driver_id: nil } }
        }.not_to change(Shift, :count)

        expect(response).to redirect_to(new_shift_path)
        expect(flash[:alert]).to eq("Driver is required to create a shift.")
      end
    end

    context "with invalid driver_id" do
      it "does not create a shift and redirects to new_shift_path with an alert" do
        expect {
          post :create, params: { shift: { date: Date.today, shift_type: "evening", driver_id: 9999 } }
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
    context "with valid parameters" do
      it "updates the shift and redirects to the shift page" do
        patch :update, params: { id: @shift.id, shift: { shift_type: "night" } }
        @shift.reload
        expect(@shift.shift_type).to eq("night")
        expect(response).to redirect_to(@shift)
      end
    end

    context "with invalid parameters" do
      it "does not update the shift and re-renders the edit template" do
        patch :update, params: { id: @shift.id, shift: { date: nil } }
        @shift.reload
        expect(@shift.date).not_to be_nil
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "PATCH #update with commit_type feedback" do
    it "updates shift and redirects to driver's today page" do
      patch :update, params: { id: @shift.id, shift: { shift_type: "feedback_type" }, commit_type: "feedback" }
      @shift.reload
      expect(@shift.shift_type).to eq("feedback_type")
      expect(response).to redirect_to(today_driver_path(id: @shift.driver_id))
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

  describe "GET #shifts_for_day" do
    render_views
    it "returns a json object with the list of shift descriptions and id's" do
      shift1 = FactoryBot.create(:shift, shift_type: "pm", date: "2025-05-22")
      shift2 = FactoryBot.create(:shift, shift_type: "am", date: "2025-05-22")
      FactoryBot.create(:shift, date: "2025-05-23")
      FactoryBot.create(:shift, date: "2025-05-21")

      get :shifts_for_day, params: {date: "2025-05-22"}

      expected_list = [shift1, shift2].map {|shift| { "text" => "#{shift.shift_type} shift with driver #{shift.driver.name}", "value" => shift.id }}

      expect(JSON.parse(response.body)).to include(*expected_list)
    end
  end
end
