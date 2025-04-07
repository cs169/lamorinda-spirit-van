Feature: Filtering Passengers

  Background:
    Given the following passenger records exist:
        | Name        | Street           | City        | State | Zip   | Birthday   | Race | Hispanic? | Date Registered |
        | Jane Doe    | 123 Main St      | Lafayette   | CA    | 94549 | 1940-01-01 | 5    | true      | 2022-06-01      |
        | John Smith  | 456 Oak Rd       | Orinda      | CA    | 94550 | 1935-05-12 | 5    | false     | 2021-11-15      |
        | Mary Brown  | 789 Pine Ave     | Moraga      | CA    | 94551 | 1942-09-25 | 5    | true      | 2023-01-10      |
    And I am on the passengers page

  @javascript
  Scenario: Filtering the Passengers Table with basic search
    When I fill in the search field with "Mary"
    Then I should see "Mary" in the table
    And I should not see "Leah" in the table

  @javascript 
  Scenario: Filtering the Passengers Table with case-insensitive search
    When I fill in the search field with "mary"
    Then I should see "Mary" in the table
    And I should not see "Leah" in the table

  @javascript 
  Scenario: Filtering the Passengers Table with partial name search
    When I fill in the search field with "Ma"
    Then I should see "Mary" in the table
    And I should not see "Leah" in the table

  @javascript
  Scenario: Filtering the Passengers Table with trailing white space search
    When I fill in the search field with "             Mary"
    Then I should see "Mary" in the table
    And I should not see "Leah" in the table

  @javascript
  Scenario: Filtering the Passengers Table with no valid searches
    When I fill in the search field with "Andrew"
    Then I should not see any entries in the table
    And I should not see "Leah" in the table
