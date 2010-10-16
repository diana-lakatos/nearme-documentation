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

@wip
Scenario: A user can successfully create a workplace
  Given I go to the new workplace page
   When event
   Then outcome
