# frozen_string_literal: true

require "rails_helper"

RSpec.describe PassengersController, type: :controller do
  before(:each) do
    @user = FactoryBot.create(:user, :dispatcher)
    sign_in @user

    @address1 = FactoryBot.create(:address)
    @passenger1 = FactoryBot.create(:passenger)
    @passenger2 = FactoryBot.create(:passenger)
  end

  describe "POST #create" do
    it "GET #new" do
      get :new
      expect(response).to have_http_status(:success)
    end

    # Tests successful creation of a passenger
    # it "creates a new passenger and redirects" do
    #   puts(valid_attributes)
    #   post :create, params: { passenger: valid_attributes }
    #   expect(response).to redirect_to(passengers_path)
    #   expect(flash[:notice]).to eq("Passenger was successfully created.")
    # end

    # Tests failed creation due to missing required parameters
    it "renders new when passenger creation fails" do
      post :create, params: { passenger: { address_id: nil } }
      expect(response).to render_template(:new)
    end
  end

  describe "PUT #update" do
    # Tests successful update of a passenger
    it "updates the passenger and redirects" do
      put :update, params: { id: @passenger1.id, passenger: { name: "Updated Name" } }
      expect(response).to redirect_to(edit_passenger_path(@passenger1))
      expect(flash[:notice]).to eq("Passenger updated.")
    end
  end
end
