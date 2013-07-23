@javascript
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Background:
    Given I am on the home page

  Scenario: A user searches for nothing
    When I search for ""
    Then I should see "No results found"

  Scenario: A user searches for something silly
    When I search for "bung"
    Then I should see "No results found"

  Scenario: A user searches for something which yields no results
    When I search for "darwin"
    Then I should see "No results found"

  Scenario: A user searches for a location
    Given a listing in Cleveland exists
    And a listing in Auckland exists
    When I search for "Auckland"
    And I view the results in the map view
    Then I see the listings on a map
    And I see a search result for the Auckland listing
    And I do not see a search result for the Cleveland listing

  Scenario: Returning to the search results shows the previous results
    Given a listing in Auckland exists
      And a listing in Adelaide exists
     When I search for "Adelaide"
      And I make another search for "Auckland"
      And I leave the page and hit back
     Then I see a search result for the Auckland listing
      And I do not see a search result for the Adelaide listing

  Scenario: Searching for a listing which is fully booked
    Given a listing which is fully booked
    When I search with a date range covering the date it is fully booked
    Then that listing is not included in the search results

  Scenario: Searching for a listing which is closed on the weekends
    Given a listing which is closed on the weekend
    When I search with a date range of 2 weeks
    Then that listing is included in the search results

  Scenario: Searching without setting a date range
    Given there are listings which are unavailable
    And there are listings which are available
    When I search without setting a date range
    Then all the listings are included in the search results

