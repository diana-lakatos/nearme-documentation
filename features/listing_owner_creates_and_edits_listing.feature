Feature: Location Owner Creates/Edits Listing
  In order to let people work at my rad listing
  As a Listing Owner
  I want to create a listing listing

  Background:
    Given a user exists
    And I am logged in as the user
    And a company exists with creator: the user, name: "Garage Co"
    And a location exists with company: the company, creator: the user, name: "The Garage", description: "Aliquid eos ab quia officiis sequi."

  Scenario: A location owner can create a listing
    Given I am on the manage locations page
    And I follow "Locations"
    And I follow "Edit"
    And I follow "Listings"
    And I follow "Add a Listing"
    When I fill in "Name" with "Joe's Codin' Garage"
    And I fill in "Quantity" with "2"
    And I fill in "Description" with "Proin adipiscing nunc vehicula lacus varius dignissim."
    And I fill in "Price per day" with "50.00"
    And I choose "Yes"
    And I press "Create Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I should see "Great, your new Desk/Room has been added!"

  Scenario: A listing owner can edit a location
    When I change that locations name to Joe's Codin' Garage
    Then a location should exist with name: "Joe's Codin' Garage"

  Scenario: A location owner can delete a location
    When I delete that location
    Then that location no longer exists

  Scenario: Location has friendly url
    Given a location exists with company: the company, creator: the user, name: "Friendly url", description: "Aliquid eos ab quia officiis sequi.", formatted_address: "Ursynowska, Warsaw, Poland"
    When I visit this location page
    Then Url for this location should be friendly
    
  Scenario: Firneldy url for location work for duplicated formatted addresses
    Given a location exists with company: the company, creator: the user, name: "Friendly url", description: "Aliquid eos ab quia officiis sequi.", formatted_address: "Ursynowska, Warsaw, Poland"
      And a location exists with company: the company, creator: the user, name: "Url friendly 2", description: "Aliquid eos ab quia officiis sequi.", formatted_address: "Ursynowska, Warsaw, Poland"
    When I visit the second location page
    Then I should see the second location

