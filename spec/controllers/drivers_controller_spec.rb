# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriversController, type: :controller do
  before(:each) do
    @driver1 = Driver.create!(
      name: "Driver A",
      phone: "123-456-7890",
      email: "drivera@example.com",
      active: true
    )

    @driver2 = Driver.create!(
      name: "Driver B",
      phone: "987-654-3210",
      email: "driverb@example.com",
      active: false
    )
  end

  describe "GET #index" do
    it "assigns all drivers to @drivers" do
      get :index
      expect(assigns(:drivers)).to match_array([@driver1, @driver2])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
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
          name: "New Driver",
          phone: "555-123-4567",
          email: "newdriver@example.com",
          active: true
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

    context "with invalid attributes" do
      let(:invalid_attributes) { { name: "", phone: "" } }

      it "does not save the new driver" do
        expect {
          post :create, params: { driver: invalid_attributes }
        }.not_to change(Driver, :count)
      end

      it "renders the new template" do
        post :create, params: { driver: invalid_attributes }
        expect(response).to render_template(:new)
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

    context "with invalid attributes" do
      let(:invalid_attributes) { { name: "" } }

      it "does not update the driver" do
        patch :update, params: { id: @driver1.id, driver: invalid_attributes }
        @driver1.reload
        expect(@driver1.name).not_to eq("")
      end

      it "renders the edit template" do
        patch :update, params: { id: @driver1.id, driver: invalid_attributes }
        expect(response).to render_template(:edit)
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

  # describe "when filtering by active status" do
  #   it "returns active drivers" do
  #     get :index, params: { active: true }
  #     expect(assigns(:drivers)).to contain_exactly(@driver1)
  #   end

  #   it "returns inactive drivers" do
  #     get :index, params: { active: false }
  #     expect(assigns(:drivers)).to contain_exactly(@driver2)
  #   end
  # end

  # describe "when filtering by name" do
  #   it "returns drivers matching the specified name" do
  #     get :index, params: { name: "Driver A" }
  #     expect(assigns(:drivers)).to contain_exactly(@driver1)
  #   end
  # end

  after(:each) do
    Driver.delete_all
  end
end
