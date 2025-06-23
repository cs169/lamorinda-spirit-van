# frozen_string_literal: true

require "rails_helper"

RSpec.describe Address, type: :model do
  before(:each) do
    @address1 = FactoryBot.create(:address)
    @address2 = FactoryBot.create(:address)
  end

  describe "Full address" do
    it "is full address" do
      expect(@address1.full_address).to include(@address1.street)
      expect(@address1.full_address).to include(@address1.city)
      expect(@address1.full_address).to include(@address1.zip_code)
    end
  end

  describe "Address without zip" do
    it "is address without zip" do
      expect(@address1.address_no_zip).to include(@address1.street)
      expect(@address1.address_no_zip).to include(@address1.city)
      expect(@address1.address_no_zip).not_to include(@address1.zip_code)
    end
  end
end
