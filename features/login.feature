Feature: A user can login
  In order to let people manage their reservations
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
    When I sign up with Twitter
    Then an account should be created for that Twitter user

  Scenario: A user can login with Facebook
    Given the Facebook OAuth request is successful
    When I sign up with Facebook
    Then an account should be created for that Facebook user

  Scenario: A user can login with LinkedIn
    Given the LinkedIn OAuth request is successful
    When I sign up with LinkedIn
    Then an account should be created for that LinkedIn user


  Scenario: A user will be given error message if he fails to login with Twitter
    Given the Twitter OAuth request is unsuccessful
     When I try to sign up with Twitter
     Then there should be no Twitter account

  Scenario: A not authenticated user can not login via LinkedIn with email that exists
    Given Existing user with LinkedIn email
      And the LinkedIn OAuth request is successful
     When I sign up with LinkedIn
     Then there should be no LinkedIn account

  Scenario: An authenticated user can add Facebook 
    Given I am logged in manually  
     When I connect to Facebook
     Then account of valid user should be connected with Facebook

  Scenario: A user can login with email and password
    Given A valid user exists
     When I sign in with valid credentials
     Then I should see "Signed in successfully."

  Scenario: A user sign up with email and password
    Given There is no user with my email
     When I manually sign up with valid credentials 
     Then I am signed in as the new user




