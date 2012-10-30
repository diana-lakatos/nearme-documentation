Feature: Listing owner creates and edits location

  Background:
    Given a user exists
    And I am logged in as the user
    And a company exists with creator: the user, description: "Aliquid eos ab quia officiis sequi."

  Scenario: Creating a basic location
    When I create a location for that company
    Then I can select that location when creating listings

  Scenario: Selecting alternative currency
    When I create a location with an alternative currency
    Then that location has that alternative currency

  Scenario: With organizations
    Given an organization exists with name: "The Organization"
    When I create a location with that organization
    Then that location has that organization

  Scenario: Adding an Amenity to Location
    Given an amenity exists
    When I create a location with that amenity
    Then that location has that amenity

  Scenario: With private organizations
    Given an organization exists with name: "The Organization"
    When I create a private location with that organization
    Then that location is private to only members of it's organizations
