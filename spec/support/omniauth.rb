# frozen_string_literal: true

OmniAuth.config.test_mode = true
OmniAuth.config.logger = Logger.new(nil)

RSpec.configure do |config|
  config.after(:all) do
    OmniAuth.config.mock_auth[:entra_id] = nil
  end
end
