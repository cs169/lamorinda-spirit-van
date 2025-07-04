# frozen_string_literal: true

require "rails_helper"

RSpec.describe Passenger, type: :model do
  before(:each) do
    @passenger1 = FactoryBot.create(
      :passenger,
      hispanic: true,
      wheelchair: true,
      low_income: false,
      disabled: true,
      need_caregiver: false
    )
    @passenger2 = FactoryBot.create(
      :passenger,
      hispanic: false,
      wheelchair: false,
      low_income: true,
      disabled: false,
      need_caregiver: true
    )
  end

  describe "Hispanic" do
    it "is Hispanic" do
      expect(@passenger1.hispanic?).to eq(true)
      expect(@passenger2.hispanic?).to eq(false)
    end
  end

  describe "Boolean Attributes" do
    it "checks wheelchair, disabled, and caregiver needs" do
      expect(@passenger1.wheelchair).to eq(true)
      expect(@passenger1.disabled).to eq(true)
      expect(@passenger1.need_caregiver).to eq(false)

      expect(@passenger2.wheelchair).to eq(false)
      expect(@passenger2.disabled).to eq(false)
      expect(@passenger2.need_caregiver).to eq(true)
    end

    it "checks low_income field" do
      expect(@passenger1.low_income).to eq(false)
      expect(@passenger2.low_income).to eq(true)
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
        existing_address = create(:address, street: "123 Main St", city: "Orinda")
        passenger = create(:passenger)

        expect {
          passenger.update(address_attributes: {
            street: "123 Main St",
            city: "Orinda",
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
        existing_address = create(:address, street: "123 Shared St", city: "Orinda")

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
