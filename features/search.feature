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

  Scenario: Listing count is 0 when no listings were found
   Given a listing in Cleveland exists
     And a listing in Auckland exists
    When I search for "bung"
    Then I should see "0 results found"

  Scenario: Listing count reflects number of listings shown
   Given a listing in Cleveland exists
     And a listing in Auckland exists
     And a listing in Auckland exists
     And a listing in Auckland exists
    When I search for "Auckland"
    Then I should see "3 results found"

  Scenario: Listing count text is correctly pluralized after updated
   Given a listing in Auckland exists
    When I search for "bung"
    Then I should see "0 results found"
    When I search for "Auckland"
    Then I should see "1 result found"

  Scenario: Listing count is 0 after update that yields no results
   Given a listing in Auckland exists
    When I search for "Auckland"
    Then I should see "1 result found"
    When I search for "bung"
    Then I should see "0 results found"

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


  @wip
  Scenario: Searching for a listing which is fully booked
    Given a listing which is fully booked
    When I search with a date range covering the date it is fully booked
    Then that listing is not included in the search results

  @future
  Scenario: Searching for a listing which is closed on the weekends
    Given a listing which is closed on the weekends
    When I search with a date range of 2 weeks
    Then that listing is included in the search results

  @future
  Scenario: Searching without setting a date range
    Given there are listings which are unavailable
    And there are listings which are available
    When I search without setting a date range
    Then all the listings are included in the search results

  @future
  Scenario: A user searches with a price range
    Given a listing in Auckland exists with a price of $50.00
    And a listing in Auckland exists with a price of $10.00
    When I set the price range to $0 to $25
    And I search for "Auckland"
    Then the search results have the $10 listing
    And the search results do not have the $25 listing
