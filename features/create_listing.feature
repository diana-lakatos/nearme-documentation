Feature: A user can create and edit a listing
  In order to let people work at my rad listing
  As a user
  I want to create a listing listing

  Scenario: A user can successfully create a listing
    Given a user exists
      And I am logged in as the user
      And a location exists with creator: the user, name: "The Garage"
      And I am on the new listing page
     When I fill in "Name" with "Joe's Codin' Garage"
      And I select "The Garage" from "Location"
      And I choose "Yes"
      And I press "Create Listing"
     Then a listing should exist with name: "Joe's Codin' Garage"
      And I see the listing details

  Scenario: A user can edit a listing
    Given a user exists
      And I am logged in as the user
      And a listing exists with creator: the user
     When I go to the listing's page
      And I follow "Edit Listing"
      And I should see "Edit a listing"
      And I fill in "Name" with "Joe's Codin' Garage"
      And I press "Update Listing"
     Then a listing should exist with name: "Joe's Codin' Garage"
      And I see the listing details

  Scenario: A hacker cant edit a listing
    Given a user: "wally" exists
      And a listing exists with creator: the user "wally"
      And a user: "hacker" exists
      And I am logged in as the user: "hacker"
     When I go to the listing's edit page
      And I should not see "Edit a listing"
      And I should see "Could not find listing"

