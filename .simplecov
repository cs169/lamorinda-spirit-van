# frozen_string_literal: true

require "simplecov_json_formatter"

# Configure SimpleCov to generate both HTML and JSON reports.
# HTML is useful for local inspection; JSON is used by Codecov or other CI tools.
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,      # Generates coverage/index.html
  SimpleCov::Formatter::JSONFormatter       # Generates coverage/coverage.json for CI
])

SimpleCov.start "rails" do
  # enable_coverage :branch         # Optional: also track branch coverage
  add_filter "/spec/"            # Exclude spec files from coverage calculation
  add_filter "/features/"        # Exclude cucumber files from coverage calculation
end
