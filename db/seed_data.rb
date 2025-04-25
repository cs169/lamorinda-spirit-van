# frozen_string_literal: true

module SeedData
  def self.drivers
    [
      {
        name:         "Sarah",
        phone:        "0000000000",
        email:        "sarah@lamorinda.com",
        active:       true
      },
      {
        name:         "Mike",
        phone:        "000-000-0000",
        email:        "mike@lamorinda.com",
        active:       true
      },
      {
        name:         "John",
        phone:        "510-687-8824",
        email:        "john@lamorinda.com",
        active:       true
      },
      {
        name:         "Emily",
        phone:        "510-123-4567",
        email:        "Emily@lamorinda.com",
        active:       true
      },
      {
        name:         "Robert",
        phone:        "510-123-3333",
        email:        "",
        active:       true
      },
      {
        name:         "Mary",
        phone:        "666-999-0000",
        email:        "mary@lamorinda.com",
        active:       false
      }
    ]
  end
end
