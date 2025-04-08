Feature: Show and Hide Columns in Passengers Table

  Background:
    Given the following passenger records exist:
        | Name        | Street           | City        | State | Zip   | Birthday   | Race | Hispanic? | Date Registered |
        | Jane Doe    | 123 Main St      | Lafayette   | CA    | 94549 | 1940-01-01 | 5    | true      | 2022-06-01      |
        | John Smith  | 456 Oak Rd       | Orinda      | CA    | 94550 | 1935-05-12 | 5    | false     | 2021-11-15      |
        | Mary Brown  | 789 Pine Ave     | Moraga      | CA    | 94551 | 1942-09-25 | 5    | true      | 2023-01-10      |
    Given I am on the passengers page


@javascript
  Scenario: All columns are visible by default
    Then the "Name" column should be visible
    And the "Address" column should be visible
    And the "Phone" column should be visible
    And the "Alternative Phone" column should be visible
    And the "Birthday" column should be visible
    And the "Race" column should be visible
    And the "Hispanic" column should be visible
    And the "Email" column should be visible
    And the "Notes" column should be visible
    And the "Date Registered" column should be visible
    And the "Audit" column should be visible

@javascript
  Scenario: Hiding the "Email" column
    When I uncheck the "Email" column toggle
    Then the "Email" column should be hidden

  Scenario: Showing the "Email" column again
    Given I have hidden the "Email" column
    When I check the "Email" column toggle
    Then the "Email" column should be visible

  Scenario: Toggling multiple columns
    When I uncheck the "Phone" column toggle
    And I uncheck the "Address" column toggle
    Then the "Phone" column should be hidden
    And the "Address" column should be hidden

  
