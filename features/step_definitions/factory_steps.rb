# frozen_string_literal: true

Given(/^the following passengers exist:$/) do |names|
  data = names.raw
  data.each do |name|
    FactoryBot.create(:passenger, name: name)
  end
end

Given(/^theres some drivers/) do
  FactoryBot.create(:driver)
  FactoryBot.create(:driver)
end
