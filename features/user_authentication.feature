Feature: User authentication and role enforcement

  Background:
    Given the following user exists:
      | email             | password | role |
      | roleless@example.com | password |       |
      | admin1@example.com | password | admin |
      | dispatcher1@example.com | password | dispatcher |
      | driver1@example.com | password | driver |

  Scenario: A user can sign up with valid credentials
    Given I am on the "Sign up" page
    And I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Sign up"
    Then I should be on the "Log in" page

  Scenario Outline: A user with role <role> can sign in successfully
    Given I am on the "Log in" page
    And I fill in "Email" with "<email>"
    And I fill in "Password" with "password"
    And I press "Log in"
    Then I should be on the "Lamorinda" page

    Examples:
      | email                   | role       |
      | admin1@example.com      | admin      |
      | dispatcher1@example.com | dispatcher |
      | driver1@example.com     | driver     |


  Scenario: A user with no role cannot sign in and sees an alert
    Given I am on the "Log in" page
    And I fill in "Email" with "roleless@example.com"
    And I fill in "Password" with "password"
    And I press "Log in"
    Then I should be on the "Log in" page
    And I should see "Your account is awaiting role assignment. Please contact an admin."

