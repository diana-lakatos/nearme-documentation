Feature: A user can login
  In order to let people manage their reservations
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
      And I go to the home page
      And I follow "Log in"
     When I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "fuckyoutwitter@yourmum.com"
      And I press "Sign up"
     Then I should see "You have signed up successfully."

  Scenario: A user can login with email and password
    Given a user exists with email: "real@email.com", password: "password"
      And I go to the home page
      And I follow "Log in"
      And I fill in "Your email address" with "real@email.com"
      And I fill in "Your password" with "password"
      And I press "Log In"
     Then I should see "Signed in successfully."

  Scenario: A user sign up with email and password
    Given I go to the home page
      And I follow "Sign Up"
     When I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "real@email.com"
      And I fill in "Your password" with "password"
      And I fill in "user_password_confirmation" with "password"
      And I press "Sign up"
     Then I should see "You have signed up successfully."
      And a user should exist with email: "real@email.com"
      And that user should have password "password"

