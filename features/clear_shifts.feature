Feature: Clear all shifts for a month
    As an admin
    So I can more easily and quicky erase shifts that I filled in
    I want a button that clears all the shifts for a month

    Background:
        Given an admin is logged in
        And the current date is  March 1, 2025
        Given 5 shifts exist for March
        And 5 shifts exist for April
        And 5 shifts exist for May
        And I am on the shifts page
        
    Scenario: Clearing all shifts for the current month
        And I follow "Delete All Shifts for this Month"
        Then there should be 0 shifts for March
        And there should be 5 shifts for April
        And there should be 5 shifts for May

    Scenario: Clearing all shifts for the next month
        When I follow "Next Month"
        And I follow "Delete All Shifts for this Month"
        Then there should be 5 shifts for March
        And there should be 0 shifts for April
        And there should be 5 shifts for May