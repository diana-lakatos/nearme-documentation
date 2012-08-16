Feature: Location Owner Creates/Edits Listing
  In order to let people work at my rad listing
  As a Listing Owner
  I want to create a listing listing

  Background:

  Scenario: A location owner can create a listing
    Given a user exists
    And I am logged in as the user
    And a location exists with creator: the user, name: "The Garage", description: "Aliquid eos ab quia officiis sequi."
    And I am on the new listing page
    When I fill in "Name" with "Joe's Codin' Garage"
    And I select "The Garage" from "Location"
    And I fill in "Quantity" with "2"
    And I fill in "Price" with "50.00"
    And I fill in "Description" with "Proin adipiscing nunc vehicula lacus varius dignissim."
    And I choose "Yes"
    And I press "Create Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I see the listing details

  Scenario: Setting a price
    Given a user exists
    And I am logged in as the user
    And a location exists with creator: the user, name: "The Garage", description: "Aliquid eos ab quia officiis sequi."
    When I create a listing for that location with a price of $50.00
    Then the listing price is shown as $50

  Scenario: A listing owner can edit a listing
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

