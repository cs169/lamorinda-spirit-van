class Shift < ApplicationRecord
    belongs_to :driver
    validates :shift_date, :shift_type, presence: true
end
