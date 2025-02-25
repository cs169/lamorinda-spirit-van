class Passenger < ApplicationRecord
    validates :first_name, :last_name, :full_name, :address, :city, presence: true
    validates :state, presence: true, inclusion: { in: [ "CA" ] }
end
