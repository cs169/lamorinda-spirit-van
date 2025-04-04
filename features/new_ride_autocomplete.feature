@javascript
Feature: Autocomplete for new ride passengers
    As a dispatcher
    So I can more easily and quicky create new Rides
    I want the website to autocomplete and autofill passenger info 

    Background:
        Given I am logged in as a dispatcher
        And the following passengers exist:
            | Alice   |
            | Bob     |
            | Bill    |
            | Charlie |
        And theres some drivers and stuff
        And I am on the new ride page

    Scenario: Autocomplete prompts names as you type
        When I fill in "Passenger" with "B"
        Then I should see "Bob"
        And I should see "Bill"
        And I should not see "Alice"