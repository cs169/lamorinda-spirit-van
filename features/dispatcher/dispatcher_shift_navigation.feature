Feature: Dispatcher Shift Navigation

  As a dispatcher
  I want to navigate between shifts and driver pages
  So that I can easily review driver schedules and shift details

  Background:
    Given a dispatcher is logged in
    
    Given the following driver exists:
      | name       |
      | John Smith |
    And the following shift exists:
      | driver     | shift_date | shift_type |
      | John Smith | Time.zone.today | am |
    And I am on the shifts calendar page

  Scenario: Dispatcher clicks on driver name to view their upcoming shifts
    When I click on a driver's name
    Then I should be on the Driver's Upcoming Shifts page
    And I should see a list of upcoming shifts belonging to that driver

  Scenario: Dispatcher clicks on shift type to view shift details
    When I click on a shift type
    Then I should be on the Shift Details page
    And I should see the details of that shift
