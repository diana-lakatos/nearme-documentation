@javascript
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Scenario: A user searches for nothing
    When I search for ""
    Then I should see "Please enter a city or address"

  Scenario: A user searches for something silly
    When I search for "bung"
    Then I should see "Please enter a city or address"

  Scenario: A user searches for something which yields no results
    When I search for "darwin"
    Then I should see "No results found"

  Scenario: A user searches for a location
    Given a listing in Auckland exists
    And a listing in Cleveland exists
    When I search for "Auckland"
    Then I see the listings on a map
    And I see a search result for the Auckland listing
    And I do not see a search result for the Cleveland listing


  @future
  Scenario: a non member user searches for a private listing

  @future
  Scenario: a member user searches for a private listing
