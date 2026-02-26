Feature: Create a shift template
  As an admin
  So that I can efficiently create shifts for drivers
  I want to successfully create a shift template without encountering errors

  Background:
    Given an admin is logged in
    And the following drivers exist:
      | name  |
      | Alice |

  Scenario: Admin creates a shift template and is redirected to the shifts calendar
    Given I go to the new shift template page
    When I fill in "Shift type" with "am"
    And I select "Monday" from "Day of week"
    And I select "Alice" from "Driver"
    And I press "Create Shift template"
    Then I should be on the shifts calendar page
    And I should see "Shift template was successfully created."

  Scenario: Admin creates a shift template via the calendar and lands on the same month
    Given I am on the new shift template page with start date "2025-03-01"
    When I fill in "Shift type" with "pm"
    And I select "Tuesday" from "Day of week"
    And I select "Alice" from "Driver"
    And I press "Create Shift template"
    Then I should be on the shifts calendar page
    And I should see "Shift template was successfully created."

  Scenario: Admin submits an incomplete shift template form and sees validation errors
    Given I go to the new shift template page
    When I select "Wednesday" from "Day of week"
    And I select "Alice" from "Driver"
    And I press "Create Shift template"
    Then I should see "prohibited this shift_template from being saved"
    And I should not see "Shift template was successfully created."

  Scenario: Admin edits a shift template and is redirected to the shifts calendar
    Given a shift template exists for "Alice" on "Monday" with type "am"
    When I am on the edit shift template page
    And I fill in "Shift type" with "pm"
    And I press "Update Shift template"
    Then I should be on the shifts calendar page
    And I should see "Shift template was successfully updated."
