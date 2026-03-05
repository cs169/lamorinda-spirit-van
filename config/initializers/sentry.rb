# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = "https://868909cbd4cb584e373e0d645a139488@o4510989335855104.ingest.us.sentry.io/4510989337034752"
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end
