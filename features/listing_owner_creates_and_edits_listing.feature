Feature: Location Owner Creates/Edits Listing
  In order to let people work at my rad listing
  As a Listing Owner
  I want to create a listing listing

  Background:
    Given a user exists
    And I am logged in as the user
    And a location exists with creator: the user, name: "The Garage", description: "Aliquid eos ab quia officiis sequi."

  Scenario: A location owner can create a listing
    Given I am on the new listing page
    When I fill in "Name" with "Joe's Codin' Garage"
    And I select "The Garage" from "Location"
    And I fill in "Quantity" with "2"
    And I fill in "Daily price" with "50.00"
    And I fill in "Description" with "Proin adipiscing nunc vehicula lacus varius dignissim."
    And I choose "Yes"
    And I press "Create Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I see the listing details


  Scenario: Creating a listing for a location that is an alternative currency
    Given a location exists with creator: the user, name: "The Other Place", description: "Cool beans", currency: "GBP"
    When I create a listing for that location with a daily price of £50.00
    Then the listing daily price is shown as £50

  Scenario: Setting a price
    When I create a listing for that location with a daily price of $50.00
    Then the listing daily price is shown as $50

  Scenario: Setting a weekly price
    When I create a listing for that location with a weekly price of $200.00
    Then the listing weekly price is shown as $200

  Scenario: Setting a monthly price
    When I create a listing for that location with a monthly price of $400.00
    Then the listing monthly price is shown as $400

  @future
  Scenario: Setting availability rules
    When I create a listing for that location with availability rules
    Then the listing shows the availability rules

  Scenario: A listing owner can edit a listing
    Given a listing exists with creator: the user
    When I go to the dashboard
    And I follow "Manage Spaces"
    And I follow "Edit Listing"
    And I should see "Edit a listing"
    And I fill in "Name" with "Joe's Codin' Garage"
    And I press "Update Listing"
    Then a listing should exist with name: "Joe's Codin' Garage"
    And I see the listing details
