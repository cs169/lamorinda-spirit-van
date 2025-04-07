Feature: Driver Ride and Shift Navigation

  As a driver
  I want to view my rides and shifts
  So that I can review my schedule efficiently

  Background:
    Given a driver is logged in

  Scenario: Viewing monthly shifts from Today's Rides
    Given I am on Today's Rides page for that driver
    Then I should see "View All Shifts" button
    When I click on "View All Shifts" button
    Then I should be on the "Shifts" page

  Scenario: Viewing the current month in the shift calendar
    Given I am on the "Shifts" page
    Then I should see the current month and year in the calendar title

  Scenario: Driver can switch month
    Given I am on the "Shifts" page
    Then I should see the "Last Month", "Jump to Today", and "Next Month" buttons
    And I should see the current month title

    When I click on "Last Month" button
    Then I should see the previous month title

    When I click on "Jump to Today" button
    Then I should see the current month title

    When I click on "Next Month" button
    Then I should see the next month title
