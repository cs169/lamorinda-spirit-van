class Driver < ApplicationRecord
    validates :name, :phone, presence: true
    validates :email, :active, presence: false
end
