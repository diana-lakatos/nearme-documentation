@javascript
Feature: Liquid views should be correctly rendered
  Background:
    Given a user exists
    Given some listings exists

  Scenario: search/mixed/individual_listing
    When search settings are mixed individual listing
    And I am on the home page
    When I search for ""
    Then I should be able to see three locations
    And I should be able to see three listings