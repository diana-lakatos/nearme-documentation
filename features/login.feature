Feature: A user can login with facebook or twitter
  In order to let people manage their bookings
  As a user
  I want to login

  Scenario: A user can login with Twitter
    Given the Twitter OAuth request is successful
      And I go to the home page
      And I follow "Sign In"
     When I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Email" with "fuckyoutwitter@yourmum.com"
      And I press "Sign up"
     Then I should see "You have signed up successfully. If enabled, a confirmation was sent to your e-mail."
