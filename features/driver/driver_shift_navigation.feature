Feature: Driver Ride and Shift Navigation

  As a driver
  I want to view my rides and shifts
  So that I can review my schedule efficiently

  Background:
    Given a driver is logged in

  Scenario: Viewing monthly shifts from Today's Rides
    Given I visit the Today's Rides page for that driver
    Then I should see "View All Shifts" button
    When I click on "View All Shifts" button
    Then I should be on the shifts calendar page

  Scenario: Viewing the current month in the shift calendar
    Given I am on the shifts calendar page
    Then I should see the current month and year in the calendar title

  Scenario: Driver can switch month
    Given I am on the shifts calendar page
    Then I should see the "Last Month", "Jump to Today", and "Next Month" buttons
    And I should see the current month title

    When I follow "Last Month"
    Then I should see the previous month title

    When I follow "Jump to Today"
    Then I should see the current month title

    When I follow "Next Month"
    Then I should see the next month title
