Feature: An admin can edit shit
  In order to keep the site free of dicks
  As a user
  I want to be able to moderate

  Scenario: An admin can edit a listing
    Given a user: "wally" exists
      And a listing exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the listing's edit page
      And I should see "Edit a listing"
      And I should see "Creator"

  Scenario: An admin can successfully create a listing with another creator
    Given a user: "Stevey" exists with name: "Stevey"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
      And a location exists with creator: the user "Adminardo", name: "The Pit of Despair", description: "Aliquid eos ab quia officiis sequi."
      And I am on the new listing page
     When I fill in "Name" with "Joe's Codin' Garage"
      And I select "The Pit of Despair" from "Location"
      And I fill in "Quantity" with "2"
      And I fill in "Daily price" with "50.00"
      And I fill in "Description" with "Proin adipiscing nunc vehicula lacus varius dignissim."
      And I select "Stevey" from "Creator"
      And I choose "Yes"
      And I press "Create Listing"
     Then 1 listings should exist with name: "Joe's Codin' Garage"
      And I should be on the listing's page
      And I see the listing details

  Scenario: An admin can edit another persons listing
    Given a user: "wally" exists with name: "Wally"
      And a user: "steve" exists with name: "Stevey"
      And a listing exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the listing's page
      And I follow "Edit Listing"
      And I should see "Edit a listing"
      And I fill in "Name" with "Joe's Codin' Garage"
      And I select "Stevey" from "Creator"
      And I press "Update Listing"
     Then a listing should exist with name: "Joe's Codin' Garage"
      And I should be on the listing's page
      And I see the listing details

  Scenario: An admin can delete a listing
    Given a user: "wally" exists with name: "Wally"
      And a listing exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the listing's page
      And I follow "Destroy (Admin Only)"
     Then I should be on the home page
      And I should see "Destroyed :("
      And a listing should not exist with name: "Joe's Codin' Garage"

