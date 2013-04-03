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

  Scenario: A user can login with LinkedIn
   Given the LinkedIn OAuth request is successful
     And I am logged in manually
    When I want connect to Facebook that belongs to other user
    Then I should not be relogged as other user

  Scenario: A user will be given error message if he fails to login with Twitter
    Given the Twitter OAuth request is unsuccessful
     When I try to sign up with Twitter
     Then there should be no Twitter account

  Scenario: A not authenticated user can not login via LinkedIn with email that exists
    Given Existing user with LinkedIn email
      And the LinkedIn OAuth request is successful
     When I sign up with LinkedIn
     Then there should be no LinkedIn account

  Scenario: Already existing user without avatar gets facebook's picture as avatar when connected
    Given I am logged in manually
      And I do not have avatar
      And the Facebook OAuth request is successful
     When I connect to Facebook
     Then I do have avatar

  Scenario: User who creates account via facebook should have avatar from facebook
    Given the Facebook OAuth request is successful
     When I sign up with Facebook
     Then I do have avatar

  Scenario: User signed up with social provider can set up his password
    Given I signed up with LinkedIn without password
     When I type in my password in edit page
     Then I should have password

  Scenario: User created via LinkedIn after updating password should be able to disconnect LinkedIn
    Given I signed up with LinkedIn with password
     When I disconnect LinkedIn
     Then there should be no LinkedIn account

  Scenario: User with one login possibility should not be able to disconnect authentication
    Given I signed up with Twitter without password
     When I want to disconnect Twitter
     Then I cannot disconnect Twitter

  Scenario: An authenticated user can add Facebook
    Given I am logged in manually
     When I connect to Facebook
     Then account of valid user should be connected with Facebook

  Scenario: A user can login with email and password
    Given a user exists with email: "valid@example.com", password: "password", name: "I am user"
     When I sign in with valid credentials
     Then I am correctly signed in

  Scenario: A user is automatically remembered
    Given a user exists with email: "valid@example.com", password: "password", name: "I am user"
     When I sign in with valid credentials
     Then I am remembered

  Scenario: A user is redirected to the page accessed prior to login page after successful logging in
    Given a user exists with email: "valid@example.com", password: "password", name: "I am user"
      And a listing in Auckland exists
      And I performed search for "Auckland"
     When I navigate away via Log In link and sign in
     Then I should be redirected to the previous search page

  Scenario: A user is not redirected to the page accessed prior to login page after failure in logging in
    Given a user exists with email: "valid@example.com", password: "password", name: "I am user"
      And a listing in Auckland exists
      And I performed search for "Auckland"
     When I sign in with invalid credentials
     Then I should not be redirected to the previous search page

  Scenario: A user sign up with email and password
    Given There is no user with my email
     When I manually sign up with valid credentials
     Then I am correctly signed in
      And I should see an indication I've just signed in
