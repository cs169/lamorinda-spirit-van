# frozen_string_literal: true

json.extract! shift, :id, :shift_date, :shift_type, :created_at, :updated_at
json.url shift_url(shift, format: :json)
