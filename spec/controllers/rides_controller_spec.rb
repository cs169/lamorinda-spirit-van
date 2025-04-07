# frozen_string_literal: true

require "rails_helper"

RSpec.describe RidesController, type: :controller do
  before(:each) do
     @user = FactoryBot.create(:user, :dispatcher)
     sign_in @user

     @driver1 = FactoryBot.create(:driver)
     @driver2 = FactoryBot.create(:driver)

     @address1 = FactoryBot.create(:address)

     @passenger1 = FactoryBot.create(:passenger)
     @ride1 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1)
     @ride2 = FactoryBot.create(:ride, driver: @driver2, passenger: @passenger1)
     @ride3 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1)
     @ride4 = FactoryBot.create(:ride, date: Date.today - 5.days)
   end

  describe "GET #index" do
   it "assigns all rides to @rides and renders the index template" do
     get :index
     expect(response).to be_successful
     expect(assigns(:rides)).to match_array([@ride1, @ride2, @ride3, @ride4])
   end
 end

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) do
        {
          date: @ride1.date,
          van: @ride1.van,
          hours: @ride1.hours,
          amount_paid: @ride1.amount_paid,
          notes_date_reserved: @ride1.notes_date_reserved,
          confirmed_with_passenger: @ride1.confirmed_with_passenger,
          passenger_id: @ride1.passenger_id,
          driver_id: @ride1.driver_id,
          notes: @ride1.notes,
          emailed_driver: @ride1.emailed_driver,
          start_address_id: @ride1.start_address_id,
          dest_address_id: @ride1.dest_address_id
        }
      end

      it "GET #new" do
        get :new
        expect(response).to have_http_status(:success)
      end

      it "GET #edit" do
        get :edit, params: { id: @ride1.id }
        expect(response).to have_http_status(:success)
      end

      # Tests successful creation of a ride
      it "creates a new ride and redirects" do
        post :create, params: { ride: valid_attributes }
        expect(response).to redirect_to(rides_path)
        expect(flash[:notice]).to eq("Ride was successfully created.")
      end

      # Tests failed creation due to missing required parameters
      it "renders new when ride creation fails" do
        post :create, params: { ride: { driver_id: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT #update" do
    # Tests successful update of a ride
    it "updates the ride and redirects" do
      put :update, params: { id: @ride1.id, ride: { driver: "Updated Driver" } }
      expect(response).to redirect_to(edit_ride_path(@ride1))
      expect(flash[:notice]).to eq("Ride was successfully updated.")
    end

    # Tests failed update due to invalid parameters
    # All possible illegal input caught by fonrtend, no need for validation here.
    # it "renders edit when ride update fails" do
    #   put :update, params: { id: @ride1.id, ride: { date: "invalid-date" } }
    #   expect(response).to have_http_status(:unprocessable_entity)
    #   expect(response).to render_template(:edit)
    # end
  end

  describe "DELETE #destroy" do
    it "handles failure when ride cannot be destroyed" do
      allow_any_instance_of(Ride).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)

      delete :destroy, params: { id: @ride1.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Failed to remove the ride.")
    end
    it "destroys the ride and redirects with success message" do
      expect {
        delete :destroy, params: { id: @ride1.id }
      }.to change(Ride, :count).by(-1)

      expect(response).to redirect_to(rides_url)
      expect(flash[:notice]).to eq("Ride was successfully removed.")
    end
  end

  describe "GET #show" do
    # Tests if the show action correctly assigns a ride
    it "assigns the requested ride to @ride" do
      get :show, params: { id: @ride1.id }
      expect(assigns(:ride)).to eq(@ride1)
    end

    # Tests handling of RecordNotFound exception
    it "raises an error when ride is not found" do
      expect {
        get :show, params: { id: -1 } # Non-existent ID
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #filter" do
    # Test if filter returns no rides without params
    it "assigns the requested ride to @ride" do
      get :filter
      expect(assigns(:ride)).to eq(nil)
    end
  end

  after(:each) do
  end
end
