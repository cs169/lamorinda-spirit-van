Feature: Navigation from Homepage to Shifts Calendar

  As a driver
    I want to see my today's Rides
    So it is on the "Today's Rides" page
    I want to see my monthly's shifts
    So it is on the "Read-Only Shift Calendar" page
    I want to see all my shifts in "Read-Only Shift Calendar" page
    So I can switch month by clicking the button
  
  Scenario: Driver check today's rides, from "home" to "Today's Rides"
    Given I am on the "home" page
    When I click on "Today's Rides" button
    Then I should be on the "Today's Rides" page
    
  Scenario: Driver should see their monthly shifts on  "Read-Only Shift Calendar" page
    Given I am on the "Today's Rides" page
    Then I should see "View Shifts" button
    When I click on "View Shifts" button
    Then I should be on the "Read-Only Shift Calendar" page

  Scenario: Driver will see the month according to the table cell he/she clicks
    Given I am on the "Read-Only Shift Calendar" page
    Then I should see the current month and year in the calendar title
  
  Scenario: Driver can switch month
    Given I am on the "Read-Only Shift Calendar" page
    Then I should see "Last Month" "Jump to Today" "Next Month" button
    When I note the current month title
    When I click on "Last Month" button
    Then I should see the month title change
    When I click on "Jump to Today" button
    Then I should see the current month title again
    When I click on "Next Month" button
    Then I should see the month title change

  
  Scenario: Dispathcer wants to create new shifts
    # As I am a dispacther, I want to manually create shifts based on driver's email
    Given I am on the "Shifts Calendar" page
    Then I should see each day has a button for create a new shift
    When I click one day's "New shift" button
    Then I should be on the "New Shift" page
    And the date should initially be the date of the corresponding table
