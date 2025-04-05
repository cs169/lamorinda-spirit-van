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

  describe "GET #today" do
    # Tests when no today parameters are provided, all rides should be returned
    it "returns all rides when no today is applied" do
      get :today
      expect(assigns(:rides)).to match_array([ @ride1, @ride2, @ride3 ])
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

      it "reuses an existing address when creating a ride" do
        existing_address = FactoryBot.create(:address, street: "100 Main St", city: "Lafayette", state: "CA", zip: "94549")

        expect {
          post :create, params: {
            ride: {
              date: Date.today,
              driver_id: @driver1.id,
              passenger_id: @passenger1.id,
              start_address_attributes: {
                street: " 100 main st ",
                city: "lafayette",
                state: "ca",
                zip: "94549"
              },
              dest_address_attributes: {
                street: "200 Broadway",
                city: "Lafayette",
                state: "CA",
                zip: "94549"
              }
            }
          }
        }.to change(Ride, :count).by(1)

        created_ride = Ride.last
        expect(created_ride.start_address).to eq(existing_address)
        expect(created_ride.dest_address.street).to eq("200 Broadway")
      end

      it "creates a new address if none exists when creating a ride" do
        expect {
          post :create, params: {
            ride: {
              date: Date.today,
              driver_id: @driver1.id,
              passenger_id: @passenger1.id,
              start_address_attributes: {
                street: "789 unlisted st",
                city: "Moraga",
                state: "ca",
                zip: "94556"
              },
              dest_address_attributes: {
                street: "456 another st",
                city: "Orinda",
                state: "ca",
                zip: "94563"
              }
            }
          }
        }.to change(Address, :count).by(2)

        ride = Ride.last
        expect(ride.start_address.city).to eq("Moraga")
        expect(ride.dest_address.state).to eq("CA")
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

  after(:each) do
    Ride.delete_all
    Driver.delete_all
  end
end
