@javascript
Feature: Liquid views should be correctly rendered
  Scenario: search/mixed/individual_listing
    Given some listings exists
      And search settings are mixed individual listing
     When I go to the search page
     Then I should be able to see three locations
      And I should be able to see three listings