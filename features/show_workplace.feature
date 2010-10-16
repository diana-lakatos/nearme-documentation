Feature: A user can see a workplace
  In order to make a booking on a workplace
  As a user
  Can wee a workplace

Scenario: A user can see a workplace
  Given a workplace exists with name: "Rad Annex", description: "Its a great place to work"
   When I go to the workplace's page
   Then I should see "Rad Annex"
    And I should see "Its a great place to work"

