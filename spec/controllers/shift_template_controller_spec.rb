# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShiftTemplatesController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, :admin)
    sign_in @user

    @driver = FactoryBot.create(:driver)
    @shift_template = FactoryBot.create(:shift_template, driver: @driver)
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new  template and redirects to the shift calendar page" do
        expect {
          post :create, params: { shift_template: {  day_of_week: 2, shift_type: "pm", driver_id: @driver.id } }
        }.to change(ShiftTemplate, :count).by(1)

        expect(response).to redirect_to(shifts_path)
      end
    end

    context "with empty shift_type" do
      it "does not create a shift template and re-renders the form" do
        expect {
          post :create, params: { shift_template: {  day_of_week: 2, shift_type: "", driver_id: @driver.id } }
        }.not_to change(Shift, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    it "returns a successful response" do
      get :edit, params: { id: @shift_template.id }
      expect(response).to be_successful
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "updates the shift and redirects to the shift page" do
        patch :update, params: { id: @shift_template.id, shift_template: { shift_type: "night" } }
        @shift_template.reload
        expect(@shift_template.shift_type).to eq("night")
        expect(response).to redirect_to(shifts_path)
      end
    end

    context "with invalid parameters" do
      it "does not update the shift and re-renders the edit template" do
        patch :update, params: { id: @shift_template.id, shift_template: { day_of_week: nil } }
        @shift_template.reload
        expect(@shift_template.day_of_week).not_to be_nil
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the shift template and redirects to the shifts index" do
      expect {
        delete :destroy, params: { id: @shift_template.id }
      }.to change(ShiftTemplate, :count).by(-1)

      expect(response).to redirect_to(shifts_path)
    end
  end
end
