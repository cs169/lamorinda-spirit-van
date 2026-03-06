Feature: Rides index pagination
  As a dispatcher
  So that the rides page loads quickly
  I want to see rides loaded 50 at a time with navigation to access all of them

  Background:
    Given a dispatcher is logged in
    And 51 rides exist

  Scenario: User sees 50 rides on page 1
    When I visit the rides index page
    Then I should see 50 rides in the table
    And I should see pagination controls

  Scenario: User navigates to page 2 and sees remaining rides
    When I visit the rides index page
    And I click on page "2" in the pagination
    Then I should see 1 ride in the table
