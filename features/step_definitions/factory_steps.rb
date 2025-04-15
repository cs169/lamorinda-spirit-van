# frozen_string_literal: true

Given(/^the following (driver|passenger|shift template)s exist:$/) do |model, table|
  table.hashes.each do |args|
    FactoryBot.create(model.parameterize(separator: "_").to_sym, args)
  end
end

Given(/^theres some drivers/) do
  FactoryBot.create(:driver)
  FactoryBot.create(:driver)
end
