# frozen_string_literal: true

json.extract! feedback, :id, :companion, :mobility, :note, :pick_up_time, :drop_off_time, :fare, :created_at, :updated_at
json.url feedback_url(feedback, format: :json)
