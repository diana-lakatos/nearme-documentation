@javascript
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Background:
    Given I am on the home page

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
    Given a listing in Cleveland exists
    And a listing in Auckland exists
    When I search for "Auckland"
    Then I see the listings on a map
    And I see a search result for the Auckland listing
    And I do not see a search result for the Cleveland listing

  Scenario: Search result is remembered
    Given a listing in Auckland exists
    When I search for "Auckland"
     And I leave and come back
    Then I see a search result for the Auckland listing

  Scenario: Search result can be overwritten
    Given a listing in Auckland exists
      And a listing in Adelaide exists
     When I search for "Adelaide"
      And I make another search for "Auckland"
      And I leave and come back
     Then I see a search result for the Auckland listing
      And I do not see a search result for the Adelaide listing

  Scenario: A user searches with a price range
    Given a listing in Auckland exists with a price of $50.00
    And a listing in Auckland exists with a price of $10.00
    When I set the price range to $0 to $25
    And I search for "Auckland"
    Then the search results have the $10 listing first
