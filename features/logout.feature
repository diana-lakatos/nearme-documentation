Feature: A user can logout of the site
  In order for something to quit my session
  As a user
  I want to logout

Scenario: A user can logout
  Given a user exists
    And I am logged in as the user
   When I go to the home page
    And I follow "Logout"
   Then I should be logged out
