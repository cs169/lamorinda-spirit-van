Feature: Filtering Passengers

  Scenario: Filtering the Passengers Table
    Given I am on the passengers page
    When I fill in the search field with "Leah"
    Then I should see "Leah" in the table
    And I should not see "Mary" in the table
