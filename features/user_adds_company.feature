Feature: User Adds Company
  Background:
    Given a user exists
    And I am logged in as the user

  Scenario: Creating a basic listing
    When I create a company
    Then I can select that company when creating locations
