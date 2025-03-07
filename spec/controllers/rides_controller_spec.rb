require 'rails_helper'

RSpec.describe RidesController, type: :controller do
  before(:each) do
    @driver1 = Driver.create(name: 'Driver A', phone: '1234567890', shifts: 'pm', email: 'jd@lamorinda.com', active: true)
    @driver2 = Driver.create(name: 'Driver B', phone: '1234567890', shifts: 'pm', email: 'jd@lamorinda.com', active: true)

    today = Time.zone.today

    # warning: the weekday_abbreviation is a little diffrent from fake rides data
    # 2025-03-01 is a Friday, the weekday_abbreviation is 'Fri', but the fake rides data is 'F'
    weekday_abbreviation = today.strftime('%a')
    @ride1 = Ride.create(day: weekday_abbreviation, date: today, driver: @driver1.name, van: 6, passenger_name_and_phone: 'Brown, Patricia (555-475-3199)', passenger_address: '143 Pine Rd.', destination: 'Walnut Creek', notes_to_driver: 'Bring a mask', driver_initials: 'JD', hours: 1.5, amount_paid: 20.0, ride_count: 1, c: 'C', notes_date_reserved: '02/27/2025', confirmed_with_passenger: 'Yes', driver_email: 'sent')
    @ride2 = Ride.create(day: weekday_abbreviation, date: today, driver: @driver2.name, van: 6, passenger_name_and_phone: 'Brown, Patricia (555-475-3199)', passenger_address: '143 Pine Rd.', destination: 'Walnut Creek', notes_to_driver: 'Bring a mask', driver_initials: 'JD', hours: 1.5, amount_paid: 20.0, ride_count: 1, c: 'C', notes_date_reserved: '02/27/2025', confirmed_with_passenger: 'Yes', driver_email: 'sent')
    @ride3 = Ride.create(day: weekday_abbreviation, date: today, driver: @driver1.name, van: 6, passenger_name_and_phone: 'Brown, Patricia (555-475-3199)', passenger_address: '143 Pine Rd.', destination: 'Walnut Creek', notes_to_driver: 'Bring a mask', driver_initials: 'JD', hours: 1.5, amount_paid: 20.0, ride_count: 1, c: 'C', notes_date_reserved: '02/27/2025', confirmed_with_passenger: 'Yes', driver_email: 'sent')
  end

  describe 'GET #filter' do
    # Tests if filtering by both driver_name_text and driver_name_select returns correct rides
    it 'returns rides matching either driver_name_text OR driver_name_select' do
      get :filter, params: { driver_name_text: 'Driver A', driver_name_select: 'Driver B' }
      expect(assigns(:rides)).to match_array([ @ride1, @ride2, @ride3 ])
    end

    # Tests filtering by only driver_name_text
    it 'returns rides matching driver_name_text' do
      get :filter, params: { driver_name_text: 'Driver A' }
      expect(assigns(:rides)).to match_array([ @ride1, @ride3 ])
    end

    # Tests filtering by only driver_name_select
    it 'returns rides matching driver_name_select' do
      get :filter, params: { driver_name_select: 'Driver B' }
      expect(assigns(:rides)).to match_array([ @ride2 ])
    end

    # Tests when no filter parameters are provided, all rides should be returned
    it 'returns all rides when no filter is applied' do
      get :filter
      expect(assigns(:rides)).to match_array([ @ride1, @ride2, @ride3 ])
    end

    # Tests if all drivers are assigned correctly to @drivers variable
    it 'assigns all drivers to @drivers' do
      get :filter
      expect(assigns(:drivers)).to match_array([ 'Driver A', 'Driver B' ])
    end
  end

  describe 'POST #create' do
    # Tests successful creation of a ride
    it 'creates a new ride and redirects' do
      post :create, params: { ride: { day: 'F', date: '2025-03-01', driver: 'Driver A', van: 6, passenger_name_and_phone: 'John Doe (555-123-4567)', passenger_address: '456 Oak St.', destination: 'Pleasant Hill', notes_to_driver: 'Call before arriving', driver_initials: 'JD', hours: 2.0, amount_paid: 25.0, ride_count: 1, c: 'C', notes_date_reserved: '02/29/2025', confirmed_with_passenger: 'Yes', driver_email: 'sent' } }
      expect(response).to redirect_to(assigns(:ride))
      expect(flash[:notice]).to eq('Ride was successfully created.')
    end

    # Tests failed creation due to missing required parameters
    it 'renders new when ride creation fails' do
      post :create, params: { ride: { driver: nil } }
      expect(response).to render_template(:new)
    end
  end

  describe 'PUT #update' do
    # Tests successful update of a ride
    it 'updates the ride and redirects' do
      put :update, params: { id: @ride1.id, ride: { driver: 'Updated Driver' } }
      expect(response).to redirect_to(@ride1)
      expect(flash[:notice]).to eq('Ride was successfully updated.')
    end

    # Tests failed update due to invalid parameters
    it 'renders edit when ride update fails' do
      put :update, params: { id: @ride1.id, ride: { date: nil } } # date 是 presence: true
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
    end
  end

  describe 'DELETE #destroy' do
    it 'handles failure when ride cannot be destroyed' do
      allow_any_instance_of(Ride).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)

      delete :destroy, params: { id: @ride1.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq('Failed to remove the ride.')
    end
  end

  describe 'GET #show' do
    # Tests if the show action correctly assigns a ride
    it 'assigns the requested ride to @ride' do
      get :show, params: { id: @ride1.id }
      expect(assigns(:ride)).to eq(@ride1)
    end

    # Tests handling of RecordNotFound exception
    it 'raises an error when ride is not found' do
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
