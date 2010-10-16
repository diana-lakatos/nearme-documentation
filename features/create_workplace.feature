Feature: A user can create a workplace
  In order to let people work at my rad workplace
  As a user
  I want to create a workplace listing

Background:
  Given a user exists
    And I am logged in as the user

Scenario: A user can see the form
   When I go to the new workplace page
   Then I should see "Create a workplace"
    And I should see "Name"
    And I should see "Address"
    And I should see "Maximum desks"
    And I should see "Confirm bookings"


Scenario: A user can successfully create a workplace
  Given I am on the new workplace page
   When I fill in "Name" with "Joe's Codin' Garage"
    And I fill in "Address" with "1 St John St Launceston TAS 7250"
    And I fill in "Maximum desks" with "1"
    And I choose "Yes"
    And I press "Create Workplace"
   Then a workplace should exist with name: "Joe's Codin' Garage"
    And I should be on the workplace's page
