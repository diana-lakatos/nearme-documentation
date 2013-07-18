@javascript
Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard

  Scenario: An unregistered user starts by signing up
    Given I go to the home page
     And  I follow "List Your Space"
     And a location_type exists with name: "Business"
     And a listing_type exists with name: "Desk"
     And a industry exists with name: "Industry"
     Then I should see "Sign up to Desks Near Me"
     When I fill in "user_name" with "Brett Jones"
     And I fill in "user_email" with "brettjones@email.com"
     And I fill in "user_password" with "password"
     When I press "Sign up"
     Then I should see "List Your First Space"
     And a user should exist with email: "brettjones@email.com"
     When I fill in valid space details
     And I press "List my Space"
     Then I should see "Your space was listed!"

