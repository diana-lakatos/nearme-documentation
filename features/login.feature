Feature: A user can login
  In order to let people manage their reservations
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
      And I go to the home page
      And I follow "Sign In"
     When I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Name" with "Brett"
      And I fill in "Email" with "fuckyoutwitter@yourmum.com"
      And I press "Continue"
     Then I should see "You have signed up successfully."

  Scenario: A user can login with email and password
    Given a user exists with email: "real@email.com", password: "password"
      And I go to the home page
      And I follow "Sign In"
      And I fill in "Email" with "real@email.com"
      And I fill in "Password" with "password"
      And I press "Sign In"
     Then I should see "Signed in successfully."

  Scenario: A user sign up with email and password
    Given I go to the home page
      And I follow "Sign In"
      And I follow "Register"
     When I fill in "Name" with "Brett"
      And I fill in "Email" with "real@email.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm Password" with "password"
      And I press "Continue"
     Then I should see "You have signed up successfully."
      And a user should exist with email: "real@email.com"
      And that user should have password "password"

