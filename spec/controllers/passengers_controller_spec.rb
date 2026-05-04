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

  # ---------------------------------------------------------------------------
  # Helper that fires a DataTables JSON request with mergeable column overrides
  # ---------------------------------------------------------------------------
  def dt_get(extra_columns: {}, order_col: "1", order_dir: "asc", start: "0", length: "10")
    request.accept = "application/json"
    get :index, params: {
      draw: "1", start: start, length: length,
      order: { "0" => { column: order_col, dir: order_dir } },
      columns: extra_columns
    }
  end

  describe "GET #index" do
    it "returns http success for HTML format" do
      get :index
      expect(response).to have_http_status(:success)
    end

    context "JSON / DataTables" do
      it "returns correct top-level structure" do
        dt_get
        json = JSON.parse(response.body)
        expect(json.keys).to include("draw", "recordsTotal", "recordsFiltered", "data")
        expect(json["recordsTotal"]).to eq(Passenger.count)
        expect(json["data"]).to be_an(Array)
      end

      it "each data row has 23 columns" do
        dt_get
        json = JSON.parse(response.body)
        expect(json["data"].first.length).to eq(23)
      end

      it "paginates: returns only the requested page size" do
        dt_get(length: "1")
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(1)
        expect(json["recordsTotal"]).to eq(Passenger.count)
      end

      it "sorts ascending" do
        dt_get(order_col: "1", order_dir: "asc")
        expect(response).to have_http_status(:success)
      end

      it "sorts descending" do
        dt_get(order_col: "1", order_dir: "desc")
        expect(response).to have_http_status(:success)
      end

      it "falls back to default sort for an unmapped column index" do
        dt_get(order_col: "99")
        expect(response).to have_http_status(:success)
      end

      it "returns all records when length is -1 (export mode)" do
        dt_get(length: "-1")
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(Passenger.count)
      end

      it "filters by passenger name (column 1)" do
        search = @passenger1.name.downcase[0, 4]
        dt_get(extra_columns: { "1" => { search: { value: search } } })
        json = JSON.parse(response.body)
        expect(json["recordsFiltered"]).to be <= json["recordsTotal"]
      end

      it "filters by street (column 4)" do
        street = @passenger1.address.street.downcase[0, 4]
        dt_get(extra_columns: { "4" => { search: { value: street } } })
        expect(response).to have_http_status(:success)
      end

      it "filters by city (column 5)" do
        dt_get(extra_columns: { "5" => { search: { value: "nonexistent_xyz" } } })
        json = JSON.parse(response.body)
        expect(json["recordsFiltered"]).to eq(0)
      end

      it "filters by birthday range (column 9)" do
        dt_get(extra_columns: { "9" => { search: { value: "1900-01-01|2000-01-01" } } })
        json = JSON.parse(response.body)
        expect(json["data"]).not_to be_empty
      end

      it "ignores birthday column value without pipe separator" do
        dt_get(extra_columns: { "9" => { search: { value: "2000-01-01" } } })
        expect(response).to have_http_status(:success)
      end

      it "applies birthday from-only range" do
        dt_get(extra_columns: { "9" => { search: { value: "1900-01-01|" } } })
        expect(response).to have_http_status(:success)
      end

      it "applies birthday to-only range" do
        dt_get(extra_columns: { "9" => { search: { value: "|2000-01-01" } } })
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "dt_passenger_row data" do
    it "splits multi-word name into first and last" do
      @passenger1.update!(name: "Jane Marie Doe")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[1] == "Doe" }
      expect(row[2]).to eq("Jane Marie")
    end

    it "uses N/A for last name when passenger has a single-word name" do
      @passenger1.update!(name: "Cher")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[2] == "Cher" }
      expect(row[1]).to eq("N/A")
    end

    it "renders opt-in newsletter badge" do
      @passenger1.update!(rqsted_newsletter: "Opt-In")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[22].include?("Opt-In") }
      expect(row).not_to be_nil
    end

    it "renders neutral newsletter badge" do
      @passenger1.update!(rqsted_newsletter: "Neutral")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[22].include?("Neutral") }
      expect(row).not_to be_nil
    end

    it "renders opt-out newsletter badge" do
      @passenger1.update!(rqsted_newsletter: "Opt-Out")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[22].include?("Opt-Out") }
      expect(row).not_to be_nil
    end

    it "renders not-set newsletter badge for unknown value" do
      @passenger1.update!(rqsted_newsletter: nil)
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[22].include?("Not Set") }
      expect(row).not_to be_nil
    end

    it "truncates notes longer than 20 characters" do
      @passenger1.update!(notes: "A" * 25)
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[16].include?("…") }
      expect(row).not_to be_nil
    end

    it "does not truncate notes shorter than 20 characters" do
      @passenger1.update!(notes: "Short note")
      dt_get
      json = JSON.parse(response.body)
      row = json["data"].find { |r| r[16].include?("Short note") && !r[16].include?("…") }
      expect(row).not_to be_nil
    end

    it "returns empty string for blank notes" do
      @passenger1.update!(notes: nil)
      dt_get
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: @passenger1.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: @passenger1.id }
      expect(response).to have_http_status(:success)
    end

    it "sets safe_return_url" do
      get :edit, params: { id: @passenger1.id, return_url: "/rides/new" }
      expect(assigns(:safe_return_url)).to eq("/rides/new")
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "builds a new passenger with an associated address" do
      get :new
      expect(assigns(:passenger)).to be_a_new(Passenger)
      expect(assigns(:passenger).address).to be_a_new(Address)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name: "New Passenger",
        phone: "555-555-5555",
        email: "newpassenger@example.com",
        race: 1,
        hispanic: "Yes",
        birthday: "1950-01-01",
        date_registered: "2024-01-01",
        address_attributes: {
          street: "999 Unique Blvd",
          city: "Orinda",
          zip_code: "94563"
        }
      }
    end

    it "creates a new passenger and redirects" do
      expect {
        post :create, params: { passenger: valid_attributes }
      }.to change(Passenger, :count).by(1)
      expect(response).to redirect_to(passengers_path)
      expect(flash[:notice]).to eq("Passenger created.")
    end

    it "creates a new address when a unique one is provided" do
      expect {
        post :create, params: { passenger: valid_attributes }
      }.to change(Address, :count).by(1)
    end

    it "reuses an existing address on create" do
      existing = FactoryBot.create(:address, name: nil, street: "100 Shared Ln", city: "Lafayette", zip_code: "94549")
      attrs = valid_attributes.merge(address_attributes: {
        name: nil, street: "100 Shared Ln", city: "Lafayette", zip_code: "94549"
      })
      expect {
        post :create, params: { passenger: attrs }
      }.not_to change(Address, :count)
      expect(Passenger.last.address_id).to eq(existing.id)
    end

    it "renders new when passenger creation fails" do
      post :create, params: { passenger: { address_id: nil } }
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "appends selected_passenger_id to a valid return_url after create" do
      post :create, params: { passenger: valid_attributes, return_url: "/rides/new" }
      new_passenger = Passenger.last
      expect(response).to redirect_to("/rides/new?selected_passenger_id=#{new_passenger.id}")
    end

    it "falls back to passengers_path when return_url yields an invalid URI" do
      bad_uri = "http://?invalid:uri!"
      post :create, params: { passenger: valid_attributes, return_url: bad_uri }
      expect(response).to redirect_to(passengers_path)
    end
  end

  describe "PUT #update" do
    it "updates the passenger and redirects" do
      put :update, params: { id: @passenger1.id, passenger: { name: "Updated Name" } }
      expect(response).to redirect_to(edit_passenger_path(@passenger1))
      expect(flash[:notice]).to eq("Passenger updated.")
    end

    it "updates boolean fields correctly" do
      put :update, params: { id: @passenger1.id, passenger: { wheelchair: true, low_income: false } }
      @passenger1.reload
      expect(@passenger1.wheelchair).to eq(true)
      expect(@passenger1.low_income).to eq(false)
    end

    it "renders edit when passenger update fails" do
      allow_any_instance_of(Passenger).to receive(:update).and_return(false)
      post :update, params: { id: @passenger1.id, passenger: { phone: "1234567890" } }
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE #destroy" do
    it "destroys the passenger and redirects to passengers_path" do
      expect {
        delete :destroy, params: { id: @passenger1.id }
      }.to change(Passenger, :count).by(-1)
      expect(response).to redirect_to(passengers_path)
      expect(flash[:notice]).to eq("Passenger deleted.")
    end

    it "does not destroy the associated address record" do
      address_id = @passenger1.address_id
      delete :destroy, params: { id: @passenger1.id }
      expect(Address.exists?(address_id)).to be true
    end
  end

  describe "authorization" do
    it "redirects unauthenticated users away from index" do
      sign_out @user
      get :index
      expect(response).not_to have_http_status(:success)
    end
  end
end
