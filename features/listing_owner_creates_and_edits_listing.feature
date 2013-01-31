Feature: Location Owner Creates/Edits Listing
  In order to let people work at my rad listing
  As a Listing Owner
  I want to create a listing listing

  Background:
    Given a user exists
    And I am logged in as the user
    And a company exists with creator: the user, name: "Garage Co"
    And a listing_type exists with name: "Desk"
    And a location exists with company: the company, creator: the user, name: "The Garage", description: "Aliquid eos ab quia officiis sequi."

  Scenario: A location owner can create a listing
    Given I am on the manage locations page
    And I follow "Locations"
    And I follow "Edit"
    And I follow "Listings"
    And I follow "Add a Listing"
    When I provide valid listing information
    Then this listing should exist 

  Scenario: A listing owner can edit a location
    When I change that locations name to Joe's Codin' Garage
    Then a location should exist with name: "Joe's Codin' Garage"

  Scenario: A location owner can delete a location
    When I delete that location
    Then that location no longer exists
