Feature: Show and Hide Columns in Passengers Table

  Background:
    Given I am on the passengers page

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
