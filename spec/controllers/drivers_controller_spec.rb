# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriversController, type: :controller do
  before(:each) do
    @driver1 = FactoryBot.create(:driver)
    @driver2 = FactoryBot.create(:driver)

    @address1 = FactoryBot.create(:address)

    @passenger1 = FactoryBot.create(:passenger)
    @passenger2 = FactoryBot.create(:passenger)
    @ride1 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1)
    @ride2 = FactoryBot.create(:ride, driver: @driver2, passenger: @passenger1)
    @ride3 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger2)
    @ride4 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1, date: Time.zone.today + 1.days)
    @ride5 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1, date: Time.zone.today - 1.days)
  end

  describe "GET #index" do
    it "Verify @drivers contains all Driver records" do
      get :index
      expect(assigns(:drivers)).to match_array([@driver1, @driver2])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #today" do
    it "returns today's rides when no date is applied" do
      get :today, params: { id: @driver1.id }
      expect(assigns(:rides)).to match_array([ @ride1, @ride3 ])
    end

    it "returns yesterday's rides" do
      get :today, params: { id: @driver1.id, date: Time.zone.today - 1.days }
      expect(assigns(:rides)).to match_array([ @ride5 ])
    end

    it "returns tomorrow's rides" do
      get :today, params: { id: @driver1.id, date: Time.zone.today + 1.days }
      expect(assigns(:rides)).to match_array([ @ride4 ])
    end
  end

  describe "GET #show" do
    it "assigns the requested driver to @driver" do
      get :show, params: { id: @driver1.id }
      expect(assigns(:driver)).to eq(@driver1)
    end

    it "renders the show template" do
      get :show, params: { id: @driver1.id }
      expect(response).to render_template(:show)
    end

    it "raises an error when driver is not found" do
      expect {
        get :show, params: { id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "assigns a new driver to @driver" do
      get :new
      expect(assigns(:driver)).to be_a_new(Driver)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns the requested driver to @driver" do
      get :edit, params: { id: @driver1.id }
      expect(assigns(:driver)).to eq(@driver1)
    end

    it "renders the edit template" do
      get :edit, params: { id: @driver1.id }
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:valid_attributes) do
        {
          name: @driver1.name,
          phone: @driver1.phone,
          email: @driver1.email,
          active: @driver1.active
        }
      end

      it "creates a new driver" do
        expect {
          post :create, params: { driver: valid_attributes }
        }.to change(Driver, :count).by(1)
      end

      it "redirects to the new driver" do
        post :create, params: { driver: valid_attributes }
        expect(response).to redirect_to(Driver.last)
        expect(flash[:notice]).to eq("Driver was successfully created.")
      end
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      let(:updated_attributes) { { name: "Updated Driver Name" } }

      it "updates the driver" do
        patch :update, params: { id: @driver1.id, driver: updated_attributes }
        @driver1.reload
        expect(@driver1.name).to eq("Updated Driver Name")
      end

      it "redirects to the updated driver" do
        patch :update, params: { id: @driver1.id, driver: updated_attributes }
        expect(response).to redirect_to(@driver1)
        expect(flash[:notice]).to eq("Driver was successfully updated.")
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the driver" do
      expect {
        delete :destroy, params: { id: @driver1.id }
      }.to change(Driver, :count).by(-1)
    end

    it "redirects to drivers index" do
      delete :destroy, params: { id: @driver1.id }
      expect(response).to redirect_to(drivers_path)
      expect(flash[:notice]).to eq("Driver was successfully destroyed.")
    end

    it "raises an error when trying to delete a non-existent driver" do
      expect {
        delete :destroy, params: { id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "handles failure when driver cannot be destroyed" do
      allow_any_instance_of(Driver).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)

      delete :destroy, params: { id: @driver1.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Failed to remove the driver.")
    end
  end

  after(:each) do
    Driver.destroy_all
  end
end
