# frozen_string_literal: true

json.extract! shift_template, :id, :shift_type, :day_of_week, :driver_id, :created_at, :updated_at
json.url shift_template_url(shift_template, format: :json)
