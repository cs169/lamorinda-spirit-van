# frozen_string_literal: true

require_relative "seed_data"

Driver.destroy_all

SeedData.drivers.each do |driver|
  Driver.create(driver)
end
