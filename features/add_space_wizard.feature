Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard

  Scenario: An unregistered user starts by signing up
    Given I go to the home page
     And  I follow "List Your Space"
     And a location_type exists with name: "Business"
     And a listing_type exists with name: "Desk"
     Then I should be at the "Sign Up" step
     When I fill in "Your name" with "Brett Jones"
     And I fill in "Your email address" with "brettjones@email.com"
     And I fill in "Your password" with "password"
     When I press "Sign up"
     Then a user should exist with email: "brettjones@email.com"
     And I should be at the "List Your Space" step
     When I fill in valid space details
     And I press "List my Space"
     Then I should see "Your space was listed!"

