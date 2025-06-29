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
     @ride4 = FactoryBot.create(:ride, date: 5.days.ago)
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
          passenger_id: @ride1.passenger_id,
          driver_id: @ride1.driver_id,
          notes: @ride1.notes,
          notes_to_driver: @ride1.notes_to_driver,
          addresses_attributes: [
            {
              street: "123 Main St",
              city: "Oakland",
              state: "CA",
              zip: "94601"
            },
            {
              street: "456 Second Ave",
              city: "Berkeley",
              state: "CA",
              zip: "94704"
            },
          ]
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

      # Tests successful creation of a ride with multiple stops
      it "creates a new ride and redirects" do
        expect {
          post :create, params: { ride: valid_attributes }
        }.to change(Ride, :count).by(1)

        expect(response).to redirect_to(rides_path)
        expect(flash[:notice]).to eq("Ride was successfully created.")
      end

      # Tests failed creation due to missing required parameters
      it "renders new when ride creation fails" do
        post :create, params: { ride: { driver_id: nil } }
        expect(response).to render_template(:new)
      end

      it "creates a new ride with 3 addresses" do
        valid_attributes[:addresses_attributes] << {
          street: "789 Third Ave",
          city: "Lamorinda",
          state: "CA",
          zip: "94704"
        }
        expect {
          post :create, params: { ride: valid_attributes }
        }.to change(Ride, :count).by(2)

        expect(response).to redirect_to(rides_path)
        expect(flash[:notice]).to eq("Ride was successfully created.")
      end

      it "creates a new ride with duplicate addresses" do
        valid_attributes[:addresses_attributes] << {
          street: "456 Second Ave",
          city: "Berkeley",
          state: "CA",
          zip: "94704"
        }

        expect {
          post :create, params: { ride: valid_attributes }
        }.to change(Ride, :count).by(2)

        expect(response).to redirect_to(rides_path)
        expect(flash[:notice]).to eq("Ride was successfully created.")
      end

      it "creates a new ride with per-stop driver and van assignment" do
        attributes_with_stops = valid_attributes.merge(
          addresses_attributes: [
            { street: "123 Main St", city: "Oakland", state: "CA", zip: "94601" },
            { street: "456 Second Ave", city: "Berkeley", state: "CA", zip: "94704" },
            { street: "789 Third Ave", city: "San Francisco", state: "CA", zip: "94105" }
          ],
                  stops_attributes: [
          { driver_id: @driver1.id, van: 1 },
          { driver_id: @driver2.id, van: 2 }
        ]
        )

        expect {
          post :create, params: { ride: attributes_with_stops }
        }.to change(Ride, :count).by(2)

        created_rides = Ride.order(:created_at).last(2)
        
        # First ride should use first stop's driver and van
        expect(created_rides[0].driver_id).to eq(@driver1.id)
        expect(created_rides[0].van).to eq(1)
        
        # Second ride should use second stop's driver and van
        expect(created_rides[1].driver_id).to eq(@driver2.id)
        expect(created_rides[1].van).to eq(2)

        expect(response).to redirect_to(rides_path)
        expect(flash[:notice]).to eq("Ride was successfully created.")
      end
    end
  end

  describe "PUT #update" do
    it "updates the ride and redirects" do
      update_attrs = {
        date: Date.tomorrow,
        driver_id: @driver2.id,
        passenger_id: @passenger1.id,
        addresses_attributes: [
          {
            street: "789 Oak St",
            city: "Walnut Creek",
            state: "CA",
            zip: "94596"
          },
          {
            street: "101 Pine Rd",
            city: "Concord",
            state: "CA",
            zip: "94520"
          }
        ]
      }

      put :update, params: { id: @ride1.id, ride: update_attrs }
      new_ride = Ride.order(:created_at).last
      expect(response).to redirect_to(edit_ride_path(new_ride))
      expect(flash[:notice]).to eq("Ride was successfully updated.")
    end

    it "renders edit on failure" do
      put :update, params: { id: @ride1.id, ride: { driver_id: nil } }
      expect(response).to render_template(:edit)
    end

    it "adds a new destination to the ride chain" do
      # Start with 2 stops
      ride1 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1)
      ride2 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1, previous_ride: ride1)
      ride1.update!(next_ride: ride2)

      # New set of 3 destinations
      update_attrs = {
        date: ride1.date,
        driver_id: ride1.driver_id,
        passenger_id: ride1.passenger_id,
        addresses_attributes: [
          { street: "1 Start St", city: "A", state: "CA", zip: "90001" },
          { street: "2 Middle St", city: "B", state: "CA", zip: "90002" },
          { street: "3 End St", city: "C", state: "CA", zip: "90003" },
          { street: "4 More End St", city: "D", state: "CA", zip: "90004" },
        ]
      }

      expect {
        put :update, params: { id: ride1.id, ride: update_attrs }
      }.to change(Ride, :count).by(1)

      expect(flash[:notice]).to eq("Ride was successfully updated.")
    end

    it "removes a destination from the ride chain" do
      # Start with 3 rides
      ride1 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1)
      ride2 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1, previous_ride: ride1)
      ride3 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1, previous_ride: ride2)
      ride1.update!(next_ride: ride2)
      ride2.update!(next_ride: ride3)

      # Now send only 2 stops
      update_attrs = {
        date: ride1.date,
        driver_id: ride1.driver_id,
        passenger_id: ride1.passenger_id,
        addresses_attributes: [
          { street: "1 Start St", city: "A", state: "CA", zip: "90001" },
          { street: "2 Middle St", city: "B", state: "CA", zip: "90002" },
          { street: "3 End St", city: "C", state: "CA", zip: "90003" },
        ]
      }

      expect {
        put :update, params: { id: ride1.id, ride: update_attrs }
      }.to change(Ride, :count).by(-1)

      expect(flash[:notice]).to eq("Ride was successfully updated.")
    end

    it "updates a ride with per-stop driver and van assignment" do
      # Create initial ride chain
      ride1 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1)
      ride2 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1)
      ride1.update!(next_ride: ride2)
      ride2.update!(previous_ride: ride1)

      update_attrs = {
        date: ride1.date,
        passenger_id: ride1.passenger_id,
        addresses_attributes: [
          { street: "1 Start St", city: "A", state: "CA", zip: "90001" },
          { street: "2 Middle St", city: "B", state: "CA", zip: "90002" },
          { street: "3 End St", city: "C", state: "CA", zip: "90003" }
        ],
        stops_attributes: [
          { driver_id: @driver1.id, van: 5 },
          { driver_id: @driver2.id, van: 6 }
        ]
      }

      put :update, params: { id: ride1.id, ride: update_attrs }
      
      # Should create 2 new rides (3 addresses = 2 ride segments)
      updated_rides = Ride.order(:created_at).last(2)
      
      expect(updated_rides[0].driver_id).to eq(@driver1.id)
      expect(updated_rides[0].van).to eq(5)
      expect(updated_rides[1].driver_id).to eq(@driver2.id)
      expect(updated_rides[1].van).to eq(6)

      expect(flash[:notice]).to eq("Ride was successfully updated.")
    end
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
      expect(flash[:notice]).to eq("Ride(s) were successfully removed.")
    end

    it "destroys a ride chain and redirects with success message" do
      ride1 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1)
      ride2 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1, previous_ride: ride1)
      ride1.update!(next_ride: ride2)

      ride3 = FactoryBot.create(:ride, passenger: @passenger1, driver: @driver1, previous_ride: ride2)
      ride2.update!(next_ride: ride3)

      expect {
        delete :destroy, params: { id: ride1.id }
      }.to change(Ride, :count).by(-3)

      expect(response).to redirect_to(rides_url)
      expect(flash[:notice]).to eq("Ride(s) were successfully removed.")
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

  describe "parameter permissions" do
    it "permits stops_attributes parameter" do
      # This test ensures that stops_attributes with driver_id and van are permitted
      valid_params = {
        ride: {
          date: Date.current,
          driver_id: @driver1.id,
          passenger_id: @passenger1.id,
          addresses_attributes: [
            { street: "123 Main", city: "Oakland", state: "CA", zip: "94601" },
            { street: "456 Elm", city: "Berkeley", state: "CA", zip: "94704" }
          ],
          stops_attributes: [
            { driver_id: @driver2.id, van: "5" }
          ]
        }
      }

      expect {
        post :create, params: valid_params
      }.to change(Ride, :count).by(1)

      created_ride = Ride.last
      expect(created_ride.driver_id).to eq(@driver2.id)
      expect(created_ride.van).to eq(5)
    end

    it "ignores unpermitted parameters in stops_attributes" do
      # This test ensures that any unpermitted parameters in stops_attributes are filtered out
      valid_params = {
        ride: {
          date: Date.current,
          driver_id: @driver1.id,
          passenger_id: @passenger1.id,
          addresses_attributes: [
            { street: "123 Main", city: "Oakland", state: "CA", zip: "94601" },
            { street: "456 Elm", city: "Berkeley", state: "CA", zip: "94704" }
          ],
          stops_attributes: [
            { 
              driver_id: @driver2.id, 
              van: "5",
              malicious_param: "should_be_filtered" # This should be ignored
            }
          ]
        }
      }

      expect {
        post :create, params: valid_params
      }.to change(Ride, :count).by(1)

      created_ride = Ride.last
      expect(created_ride.driver_id).to eq(@driver2.id)
      expect(created_ride.van).to eq(5)
      # The malicious parameter should not affect the ride creation
    end
  end

  after(:each) do
  end
end
