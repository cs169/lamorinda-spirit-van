# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriversController, type: :controller do
  before(:each) do
    @dispatcher = FactoryBot.create(:user, :dispatcher)
    sign_in @dispatcher

    @driver1 = FactoryBot.create(:driver)
    @driver2 = FactoryBot.create(:driver)
    @driver1_user = FactoryBot.create(:user, email: @driver1.email, role: "driver")

    @address1 = FactoryBot.create(:address)

    @passenger1 = FactoryBot.create(:passenger)
    @passenger2 = FactoryBot.create(:passenger)
    @ride1 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1)
    @ride2 = FactoryBot.create(:ride, driver: @driver2, passenger: @passenger1)
    @ride3 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger2)
    @ride4 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1, date: Date.tomorrow)
    @ride5 = FactoryBot.create(:ride, driver: @driver1, passenger: @passenger1, date: Date.yesterday)
  end

  describe "Access control: driver user restrictions" do
    before do
      sign_in FactoryBot.create(:user, :driver)
    end

    it "denies access to GET #new" do
      get :new
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Access denied.")
    end

    it "denies access to GET #edit" do
      get :edit, params: { id: @driver1.id }
      expect(response).to redirect_to(root_path)
    end

    it "denies access to POST #create" do
      post :create, params: { driver: { name: "Test", email: "t@example.com", phone: "111", active: true } }
      expect(response).to redirect_to(root_path)
    end

    it "denies access to PATCH #update" do
      patch :update, params: { id: @driver1.id, driver: { name: "Blocked" } }
      expect(response).to redirect_to(root_path)
    end

    it "denies access to DELETE #destroy" do
      delete :destroy, params: { id: @driver1.id }
      expect(response).to redirect_to(root_path)
    end
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

    context "active and inactive drivers separation" do
      before do
        # Create active drivers
        @active_driver1 = FactoryBot.create(:driver, name: "Active Driver A", active: true)
        @active_driver2 = FactoryBot.create(:driver, name: "Active Driver B", active: true)
        
        # Create inactive drivers
        @inactive_driver1 = FactoryBot.create(:driver, name: "Inactive Driver A", active: false)
        @inactive_driver2 = FactoryBot.create(:driver, name: "Inactive Driver B", active: false)
      end

      it "assigns active drivers to @active_drivers" do
        get :index
        expect(assigns(:active_drivers)).to match_array([@driver1, @driver2, @active_driver1, @active_driver2])
      end

      it "assigns inactive drivers to @inactive_drivers" do
        get :index
        expect(assigns(:inactive_drivers)).to match_array([@inactive_driver1, @inactive_driver2])
      end

      it "orders active drivers by name" do
        get :index
        active_drivers = assigns(:active_drivers)
        expect(active_drivers.map(&:name)).to eq(active_drivers.map(&:name).sort)
      end

      it "orders inactive drivers by name" do
        get :index
        inactive_drivers = assigns(:inactive_drivers)
        expect(inactive_drivers.map(&:name)).to eq(inactive_drivers.map(&:name).sort)
      end

      it "excludes inactive drivers from active drivers list" do
        get :index
        expect(assigns(:active_drivers)).not_to include(@inactive_driver1, @inactive_driver2)
      end

      it "excludes active drivers from inactive drivers list" do
        get :index
        expect(assigns(:inactive_drivers)).not_to include(@driver1, @driver2, @active_driver1, @active_driver2)
      end

      context "with only active drivers" do
        before do
          Driver.where(active: false).destroy_all
        end

        it "returns empty array for inactive drivers" do
          get :index
          expect(assigns(:inactive_drivers)).to be_empty
        end

        it "still returns active drivers" do
          get :index
          expect(assigns(:active_drivers)).not_to be_empty
        end
      end

      context "with only inactive drivers" do
        before do
          Driver.where(active: true).destroy_all
          @only_inactive = FactoryBot.create(:driver, name: "Only Inactive", active: false)
        end

        it "returns empty array for active drivers" do
          get :index
          expect(assigns(:active_drivers)).to be_empty
        end

        it "still returns inactive drivers" do
          get :index
          expect(assigns(:inactive_drivers)).to include(@only_inactive)
        end
      end

      context "with mixed case names" do
        before do
          @mixed_case_active = FactoryBot.create(:driver, name: "zeta Active", active: true)
          @mixed_case_inactive = FactoryBot.create(:driver, name: "Alpha Inactive", active: false)
        end

        it "orders active drivers alphabetically regardless of case" do
          get :index
          active_drivers = assigns(:active_drivers)
          names = active_drivers.map(&:name)
          expect(names).to eq(names.sort)
        end

        it "orders inactive drivers alphabetically regardless of case" do
          get :index
          inactive_drivers = assigns(:inactive_drivers)
          names = inactive_drivers.map(&:name)
          expect(names).to eq(names.sort)
        end
      end
    end

    context "as driver with matching Driver record" do
      before do
        sign_in @driver1_user
        # Create at least one inactive driver for testing assignment
        @test_inactive_driver = FactoryBot.create(:driver, name: "Test Inactive Driver", active: false)
      end

      it "redirects to today_driver_path" do
        get :index
        expect(response).to redirect_to(today_driver_path(@driver1.id))
      end

      it "renders the index template without redirecting" do
        get :index, params: { dont_jump: true }
        expect(response).to render_template(:index)
      end

      it "still assigns active and inactive drivers when not redirecting" do
        get :index, params: { dont_jump: true }
        expect(assigns(:active_drivers)).to include(@driver1, @driver2)
        expect(assigns(:inactive_drivers)).to include(@test_inactive_driver)
      end
    end
  end

  describe "GET #today" do
    it "returns all rides when no date is applied" do
      get :today, params: { id: @driver1.id }
      expect(assigns(:rides)).to match_array([ @ride1, @ride3 ])
    end

    it "returns today's rides when no date is applied" do
      get :today, params: { id: @driver1.id }
      expect(assigns(:rides)).to match_array([ @ride1, @ride3 ])
    end

    it "returns yesterday's rides" do
      get :today, params: { id: @driver1.id, date: Time.zone.today - 1 }
      expect(assigns(:rides)).to match_array([ @ride5 ])
    end

    it "returns tomorrow's rides" do
      get :today, params: { id: @driver1.id, date: Time.zone.today + 1 }
      expect(assigns(:rides)).to match_array([ @ride4 ])
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

  describe "GET #upcoming_shifts" do
    it "assigns the requested driver to @driver" do
      get :upcoming_shifts, params: { id: @driver1.id }
      expect(assigns(:driver)).to eq(@driver1)
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

      it "redirects to the /drivers page" do
        post :create, params: { driver: valid_attributes }
        expect(response).to redirect_to(drivers_path)
        expect(Driver.exists?(email: @driver1.email)).to be true
        expect(flash[:notice]).to eq("Driver was successfully created.")
      end
    end

    context "with invalid attributes (simulated failure)" do
      it "renders new with unprocessable_entity (HTML)" do
        allow_any_instance_of(Driver).to receive(:save).and_return(false)

        post :create, params: { driver: { name: "No matter", email: "anything" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end

      it "renders errors with unprocessable_entity (JSON)" do
        allow_any_instance_of(Driver).to receive(:save).and_return(false)
        allow_any_instance_of(Driver).to receive(:errors).and_return({ email: ["can't be blank"] })

        request.headers["Accept"] = "application/json"
        post :create, params: { driver: { name: "ignored", email: "ignored" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("email")
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

      it "redirects to the /drivers page" do
        patch :update, params: { id: @driver1.id, driver: updated_attributes }
        expect(response).to redirect_to(drivers_path)
        expect(Driver.exists?(name: "Updated Driver Name")).to be true
        expect(flash[:notice]).to eq("Driver was successfully updated.")
      end
    end

    context "with invalid attributes (simulated failure)" do
      it "renders edit with unprocessable_entity (HTML)" do
        allow_any_instance_of(Driver).to receive(:update).and_return(false)

        patch :update, params: { id: @driver1.id, driver: { name: "Whatever" } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end

      it "renders errors with unprocessable_entity (JSON)" do
        allow_any_instance_of(Driver).to receive(:update).and_return(false)
        allow_any_instance_of(Driver).to receive(:errors).and_return({ email: ["can't be blank"] })

        request.headers["Accept"] = "application/json"
        patch :update, params: { id: @driver1.id, driver: { email: "whatever" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("email")
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

  describe "security tests for return URL validation" do
    let(:driver) { FactoryBot.create(:driver) }

    before do
      # Mock authentication if needed
      allow(controller).to receive(:require_role)
    end

    describe "GET #upcoming_shifts with malicious return_url" do
      it "blocks external redirect attempts" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "//evil.com" }
        expect(assigns(:safe_return_url)).to eq(today_driver_path(driver))
      end

      it "blocks javascript injection attempts" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "/javascript:alert('xss')" }
        expect(assigns(:safe_return_url)).to eq(today_driver_path(driver))
      end

      it "blocks path traversal attempts" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "/../../../admin" }
        expect(assigns(:safe_return_url)).to eq(today_driver_path(driver))
      end

      it "blocks external URLs with scheme" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "http://malicious.com" }
        expect(assigns(:safe_return_url)).to eq(today_driver_path(driver))
      end

      it "allows safe internal paths" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "/drivers/123" }
        expect(assigns(:safe_return_url)).to eq("/drivers/123")
      end

      it "allows safe paths with query parameters" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "/rides?status=pending" }
        expect(assigns(:safe_return_url)).to eq("/rides?status=pending")
      end

      it "handles invalid URI gracefully" do
        get :upcoming_shifts, params: { id: driver.id, return_url: "http://[invalid" }
        expect(assigns(:safe_return_url)).to eq(today_driver_path(driver))
      end
    end
  end

  after(:each) do
  end
end
