# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    OmniAuth.config.test_mode = true
  end

  config.after(:each) do
    OmniAuth.config.mock_auth[:entra_id] = nil
  end
end
