Feature: Create all shifts for a month based on a template
    As an admin
    So I can more easily and quicky create the shifts for a month
    I want the website autofill shifts for a month from a template 

    Background:
        Given an admin is logged in
        And the current date is  3/1/2025
        
    Scenario: Filling the month's shifts from the template
        Given the following shift templates exist:
            | day_of_week | shift_type | driver_name |
            | 1           | am         | Alice       |
            | 4           | pm         | Billy       |
        And I am on the shifts page
        When I press "Fill in Month with Template"
        Then there should be "am" shifts for driver "Alice" for each Monday of this month
        Then there should be "pm" shifts for driver "Billy" for each Thursday of this month
        And there should be no shifts any other month
