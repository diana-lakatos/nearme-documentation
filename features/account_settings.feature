Feature: A user can edit their settings
  In order to escape an ex-girlfriend from emailing me
  As a user
  I want to be able to change my email address

  Background:
    Given a user exists
      And the date is "13th October 2010"
      And I am logged in as the user

  Scenario: A user can successfully edit their settings
    Given I go to the account settings page
      And I fill in "Your name" with "Keith"
      And I fill in "Your email address" with "new@email.com"
     When I press "Save Changes"
     Then I should see "You updated your account successfully."
      And a user should exist with email: "new@email.com"

  Scenario: A user can badly edit their settings
    Given I go to the account settings page
      And I fill in "Your name" with ""
      And I fill in "Your email address" with ""
     When I press "Save Changes"
     Then I should see "can't be blank"

