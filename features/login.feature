Feature: A user can login with facebook or twitter
  In order to let people manage their bookings
  As a user
  I want to login

  Scenario: A user can login with Facebook
     When I go to the home page
      And I follow "Sign In"
     Then I should see "Facebook"

  Scenario: A user can login with Twitter
     When I go to the home page
      And I follow "Sign In"
     Then I should see "Twitter"
