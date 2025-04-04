Feature: Driver Ride and Shift Navigation

  As a driver
  I want to view my rides and shifts
  So that I can review my schedule efficiently

  Scenario: Navigating from Home to Today's Rides
    Given I am on the home page
    When I follow "Today's Rides"
    Then I should be on the Today's Rides page

  Scenario: Viewing monthly shifts from Today's Rides
    Given I am on the Today's Rides page
    Then I should see "View Shifts" button
    When I follow "View Shifts"
    Then I should be on the Read-Only Shift Calendar page

  Scenario: Viewing the current month in the shift calendar
    Given I am on the Read-Only Shift Calendar page
    Then I should see the current month and year in the calendar title

  Scenario: Driver can switch month
    Given I am on the Read-Only Shift Calendar page
    Then I should see the "Last Month", "Jump to Today", and "Next Month" buttons
    And I should see the current month title

    When I follow "Last Month"
    Then I should see the previous month title

    When I follow "Jump to Today"
    Then I should see the current month title

    When I follow "Next Month"
    Then I should see the next month title
