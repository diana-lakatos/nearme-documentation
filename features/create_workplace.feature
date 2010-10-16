Feature: A user can create a workplace
  In order to let people work at my rad workplace
  As a user
  I want to create a workplace listing

Scenario: A user can see the form
  Given a user exists
    And I am logged in as the user
   When I go to the new workplace page
   Then I should see "Create a workplace"




  
