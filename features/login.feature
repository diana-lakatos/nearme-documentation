Feature: A user can login
  In order to let people manage their reservations
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
    When I sign up with Twitter
    Then an account should be created for that Twitter user
    When I follow "Log Out"
    And I sign in with Twitter
    Then I should see "Log Out"

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

  Scenario: A not authenticated user can login via LinkedIn even if email do not match
    Given a user: "john" exists with email: "linkedin@example.com"
    Given a user: "maciek" exists with email: "maciek@example.com"
    Given the authentication_linkedin exists with user: user "maciek"
      And the LinkedIn OAuth request with email is successful
     When I try to sign up with LinkedIn
     Then I should be logged in as user "maciek"

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

  Scenario: User cannot sign up with OAuth if provider email already taken by another user
    Given Existing user with Facebook email
    And the Facebook OAuth request with email is successful
    And I try to sign up with Facebook
    Then I should see "is already linked to an account"
    Then there should be no Facebook account

  @fake_payments
  Scenario: User signed up with social provider can set up his password
    Given I signed up with LinkedIn without password
      And a transactable_type_listing exists with name: "Listing"
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
    Given a user exists with email: "valid@example.com", password: "password", name: "I am User"
     When I sign in with valid credentials
     Then I am correctly signed in

  Scenario: A user sign up with email and password
    Given There is no user with my email
     When I manually sign up with valid credentials
     Then I am correctly signed in
      And I should see an indication I've just signed in

  Scenario: A newly signed up user should get verification email
    Given Alerts for sign up exist
     When I manually sign up with valid credentials
     Then I should get verification email

  Scenario: A user is not signed up if tries to sign up with existing email
    Given a user exists with email: "user@example.com"
    When an anonymous user attempts to sign up with email user@example.com
    Then a new account is not created
     And I should see "Sign up to" platform name
