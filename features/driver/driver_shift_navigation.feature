Feature: Driver Ride and Shift Navigation

  As a driver
  I want to view my rides and shifts
  So that I can review my schedule efficiently

  Background:
    Given a driver is logged in

  Scenario: Driver cannot see the New Driver button
    Given I am on the drivers page
    Then I should not see "New Driver"
  
  Scenario: Navigating dates on the Today's Rides page
    Given I visit the Today's Rides page for that driver
    Then I should see "Prev. Day" button
    Then I should see "Back to Today" button
    Then I should see "Next Day" button

    When I click on "Prev. Day" button
    Then I should see the rides for one day ago

    When I click on "Prev. Day" button
    Then I should see the rides for two days ago

    When I click on "Next Day" button
    Then I should see the rides for one day ago

    When I click on "Back to Today" button
    Then I should see the rides for today


  Scenario: Returning to the same day's rides after visiting Drivers Index
    Given I visit the Today's Rides page for that driver
    Then I should see "View Other Drivers" button
    
    When I click on "Prev. Day" button
    Then I should see the rides for one day ago

    And I remember the current rides page URL

    When I click on "View Other Drivers" button
    Then I should be on the drivers page
    And I should see "Back" button

    When I click on "Back" button
    Then I should return to the remembered rides page URL
  
  Scenario: Returning to the same day's rides after visiting Drivers Index (Today)
    Given I visit the Today's Rides page for that driver
    Then I should see "View Other Drivers" button

    And I remember the current rides page URL

    When I click on "View Other Drivers" button
    Then I should be on the drivers page
    And I should see "Back" button

    When I click on "Back" button
    Then I should return to the remembered rides page URL

  Scenario: Returning to the same day's rides after visiting Upcoming Shifts Page
    Given I visit the Today's Rides page for that driver
    Then I should see "Upcoming Shifts" button
    
    When I click on "Prev. Day" button
    Then I should see the rides for one day ago

    And I remember the current rides page URL

    When I click on "Upcoming Shifts" button
    Then I should be on the driver's upcoming shifts page
    And I should see "Back" button

    When I click on "Back" button
    Then I should return to the remembered rides page URL
  
  Scenario: Returning to the same day's rides after visiting Upcoming Shifts Page(Today)
    Given I visit the Today's Rides page for that driver
    Then I should see "Upcoming Shifts" button
    
    And I remember the current rides page URL

    When I click on "Upcoming Shifts" button
    Then I should be on the driver's upcoming shifts page
    And I should see "Back" button

    When I click on "Back" button
    Then I should return to the remembered rides page URL

  Scenario: Viewing monthly shifts from Today's Rides
    Given I visit the Today's Rides page for that driver
    Then I should see "Upcoming Shifts" button
    When I click on "Upcoming Shifts" button
    Then I should be on the driver's upcoming shifts page

  Scenario: Viewing the current month in the shift calendar
    Given I am on the shifts calendar page
    Then I should see the current month and year in the calendar title

  Scenario: Driver can switch month
    Given I am on the shifts calendar page
    Then I should see the "Prev. Month", "Jump to Today", and "Next Month" buttons
    And I should see the current month title

    When I follow "Prev. Month"
    Then I should see the previous month title

    When I follow "Jump to Today"
    Then I should see the current month title

    When I follow "Next Month"
    Then I should see the next month title
