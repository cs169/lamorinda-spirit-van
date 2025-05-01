# frozen_string_literal: true

select_options = [{ value: nil, text: @prompt }]

select_options += @shifts.map do |shift|
  { text: "#{shift.shift_type} shift with driver #{shift.driver.name}", value: shift.id }
end

json.array! select_options
