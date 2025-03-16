class Address < ApplicationRecord
    has_many :passengers

    # enforce uniqueness to prevent dupliciate addresses. This is model level validation
    # but it is not the only enforcement, just one of many
    validates :street, :city, :state, :zip, presence: true
    validates :street, uniqueness: { scope: [:city, :state, :zip] }

    # Normalize data
    before_validation :normalize_fields

    private

    def normalize_fields
        self.street = street.strip.titleize
        self.city = city.strip.titleize
        self.state = state.strip.upcase
        self.zip = zip.strip
    end
end
