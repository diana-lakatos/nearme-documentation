@javascript
Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard
  Background:
    Given a location_type exists with name: "Business"
    And a listing_type exists with name: "Desk"
    And a industry exists with name: "Industry"

  Scenario: An unregistered user starts by signing up
    Given a instance exists
    And I go to the home page
     And I follow "List Your Desk"
     And I sign up as a user in the modal
     Then I should see "List Your First Desk"
     When I fill in valid space details
     And I press "List my Space"
     Then I should see "Your space was listed!"

