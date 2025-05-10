# frozen_string_literal: true

require "rails_helper"

RSpec.describe Passenger, type: :model do
  before(:each) do
    @passenger1 = FactoryBot.create(:passenger, hispanic: true)
    @passenger2 = FactoryBot.create(:passenger)
  end

  describe "Hispanic" do
    it "is Hispanic" do
      expect(@passenger1.hispanic?).to eq(true)
    end
  end

  describe "address assocations changes" do
    context "when deleting a passenger record" do
      it "does not delete the associated address record" do
        existing_address_id = @passenger1.address_id
        expect { @passenger1.destroy }.to change(Passenger, :count).by(-1)
        expect(Address.exists?(existing_address_id)).to be true
      end
    end

    context "when updating a passenger with a unique address" do
      it "creates a new address record and associates it" do
        original_address_id = @passenger2.address_id

        new_attrs = {
          street: "456 Unique St",
          city: "Newville",
          state: "CA",
          zip: "99999"
        }

        expect {
          @passenger2.update(address_attributes: new_attrs)
        }.to change(Address, :count).by(1)

        expect(@passenger2.address.street).to eq("456 Unique St".titleize)
        expect(@passenger2.address.id).not_to eq(original_address_id)
      end
    end

    context "when updating a passenger with an already existing address record" do
      it "reuses existing address when updated with matching address fields" do
        existing_address = create(:address, street: "123 Main St", city: "Orinda", state: "CA", zip: "94563")
        passenger = create(:passenger)

        expect {
          passenger.update(address_attributes: {
            street: "123 Main St",
            city: "Orinda",
            state: "CA",
            zip: "94563"
          })
        }.not_to change(Address, :count)

        expect(passenger.reload.address_id).to eq(existing_address.id)
      end
    end

    context "when creating a passenger with a unique address" do
      it "creates a new address" do
        address_attrs = {
          street: "789 Brand New Blvd",
          city: "Moraga",
          state: "CA",
          zip: "94556"
        }

        expect {
          Passenger.create!(
            name: "Unique Address Tester",
            phone: "555-555-5555",
            email: "unique@example.com",
            race: 1,
            hispanic: "Yes",
            birthday: Time.zone.today,
            date_registered: Time.zone.today,
            address_attributes: address_attrs
          )
        }.to change(Address, :count).by(1)
      end
    end

    context "when creating a passenger with an existing address" do
      it "reuses an existing address" do
        existing_address = create(:address, street: "123 Shared St", city: "Orinda", state: "CA", zip: "94563")

        passenger_attrs = {
          name: "Duplicate Address Tester",
          phone: "555-000-0000",
          email: "duplicate@example.com",
          race: 1,
          hispanic: "Yes",
          birthday: Time.zone.today,
          date_registered: Time.zone.today,
          address_attributes: {
            street: "123 Shared St",
            city:   "Orinda",
            state:  "CA",
            zip:    "94563"
          }
        }

        expect {
          Passenger.create!(passenger_attrs)
        }.not_to change(Address, :count)

        new_passenger = Passenger.last
        expect(new_passenger.address_id).to eq(existing_address.id)
      end
    end
  end
end
