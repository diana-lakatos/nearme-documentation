
Feature: User Searches Listings

  Scenario: Searching for a listing with a bounding box
    Given a listing in San Francisco exists
    And a listing in Cleveland exists
    And a listing in Auckland exists
    When I send a search request with a bounding box around New Zealand
    Then the response does include the listing in Auckland
    And the response does not include the listing in San Francisco
    And the response does not include the listing in Cleveland

  @future
  Scenario: Searching for some listings with a few price parameters
    Given a listing in Wellington exists with a price of $10.00
    And a listing in Wellington exists with a price of $25.00
    When I send a search request with a bounding box around New Zealand and prices between $0 and $20
    Then the response should have the listing for $10
    Then the response should not have the listing for $25

  @future
  Scenario: Searching for a listing with a minimum amount of desks
    Given a listing in Auckland exists with 5 desks available for the next 7 days
    And a listing in Wellington exists with 10 desks available for the next 7 days
    When I send a search request with a bounding box around New Zealand and a minimum of 7 desks
    Then the response should have the listing in Wellington
    Then the response should not have the listing in Auckland

  @future
  Scenario: Searching for a listing with dates specified as an array
    Given a listing in Auckland exists with 1 desks available for the next 1 days
    And a listing in Wellington exists with 1 desks available for the next 7 days
    When I send a search request with a bounding box around New Zealand available 2, 3, and 5 days from now
    Then the response should have the listing in Wellington
    Then the response should not have the listing in Auckland
