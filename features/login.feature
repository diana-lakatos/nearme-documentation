Feature: A user can login
  In order to let people manage their reservations
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
      And I go to the home page
      And I follow "Login"
     When I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "twitter@email.com"
      And I press "Sign up!"
     Then I should see "You have signed up successfully."

  Scenario: A user can login with Facebook
    Given the Facebook OAuth request is successful
      And I go to the home page
      And I follow "Login"
     When I follow "Facebook"
      And I grant access to the Facebook application for Facebook user "jerkcity" with ID 999
      And I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "facebook@email.com"
      And I press "Sign up!"
     Then I should see "You have signed up successfully."

  Scenario: A user can login with Linkedin
    Given the Linkedin OAuth request is successful
      And I go to the home page
      And I follow "Login"
     When I follow "LinkedIn"
      And I grant access to the LinkedIn application for LinkedIn user "jerkcity" with ID 999
      And I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "linkedin@email.com"
      And I press "Sign up!"
     Then I should see "You have signed up successfully."

  Scenario: A not authenticated user can not login via LinkedIn with email that exists
    Given Existing User with email "dont-steal-me@example.com"
      And the Linkedin OAuth request is successful
      And I go to the home page
      And I follow "Login"
     When I follow "LinkedIn"
      And I grant access to the LinkedIn application for LinkedIn user "jerkcity" with ID 999
      And I fill in "Your name" with "Brett"
      And I fill in "Your email address" with "dont-steal-me@example.com"
      And I press "Sign up!"
     Then I should not see "You have signed up successfully."

  Scenario: An authenticated user can add Facebook 
    Given Existing User with email "dont-steal-me@example.com"
      And I am logged in as the User with email "dont-steal-me@example.com"
      And the Facebook OAuth request is successful
      And I go to the home page
      And I follow "Dashboard"
     When I follow "Connect"
     Then I should see "Authentication successful"

  Scenario: A user can login with email and password
    Given a user exists with email: "real@email.com", password: "password"
      And I go to the home page
      And I follow "Login"
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
      And I press "Sign up!"
     Then I should see "You have signed up successfully."
      And a user should exist with email: "real@email.com"
      And that user should have password "password"

