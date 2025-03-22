Feature: Navigation from Homepage to Shifts Calendar

  Scenario: User click button to switch month
    Given I am on the "Read-Only Shift Calendar" page
    Then I should see the current month and year in the calendar title
    And I should see "Last Month" "Jump to Today" "Next Month" button
    When I note the current month title
    When I click on "Last Month" button
    Then I should see the month title change
    When I click on "Jump to Today" button
    Then I should see the current month title again
    When I click on "Next Month" button
    Then I should see the month title change

  Scenario: User opeate on driver's shifts
    Given I am on the "Shifts Calendar" page
    Then I should see each day has a button for create a new shift
    When I click one day's "New shift" button
    Then I should be on the "New Shift" page
    And the date should initially be the date of the corresponding table
