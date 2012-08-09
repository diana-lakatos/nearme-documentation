Feature: User Adds Location
  Background:
    Given a user exists
    And I am logged in as the user

  Scenario: Creating a basic listing
    Given a company exists with creator: the user
    When I create a location for that company
    Then I can select that location when creating listings


  @future
  Scenario: With Amenities

  @future
  Scenario: With Associations
