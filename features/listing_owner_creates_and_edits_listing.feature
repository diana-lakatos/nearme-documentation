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
    Given I am on the dashboard
    When I follow "Manage Spaces"
    And I follow "Spaces"
    And I follow "Edit"
    And I follow "Desks & Rooms"
    And I follow "Add a Desk or Room"
    When I fill in "Name" with "Joe's Codin' Garage"
    And I fill in "Quantity" with "2"
    And I fill in "Description" with "Proin adipiscing nunc vehicula lacus varius dignissim."
    And I fill in "Price per day" with "50.00"
    And I choose "Yes"
    And I press "Create Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I should see "Great, your new Desk/Room has been added!"

  @future
  Scenario: Creating a listing for a location that is an alternative currency
    Given a location exists with creator: the user, name: "The Other Place", description: "Cool beans", currency: "GBP"
    When I create a listing for that location with a daily price of £50.00
    Then the listing daily price is shown as £50

  @future
  Scenario: Setting a price
    When I create a listing for that location with a daily price of $50.00
    Then the listing daily price is shown as $50

  @future
  Scenario: Setting a weekly price
    When I create a listing for that location with a weekly price of $200.00
    Then the listing weekly price is shown as $200

  @future
  Scenario: Setting a monthly price
    When I create a listing for that location with a monthly price of $400.00
    Then the listing monthly price is shown as $400

  @future
  Scenario: Setting availability rules
    When I create a listing for that location with availability rules
    Then the listing shows the availability rules

  Scenario: A listing owner can edit a listing
    Given a listing exists with location: the location, creator: the user
    When I go to the dashboard
    And I follow "Manage Spaces"
    And I follow "Spaces"
    And I follow "Edit"
    And I follow "Desks & Rooms"
    And I follow "Edit"
    And I fill in "Name" with "Joe's Codin' Garage"
    And I press "Update Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I should see "Great, your listing's details have been updated."
