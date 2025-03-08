# frozen_string_literal: true

json.extract! driver, :id, :name, :phone, :email, :active, :created_at, :updated_at
json.url driver_url(driver, format: :json)
