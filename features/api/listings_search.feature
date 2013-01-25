
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
  Scenario: Searching for a listing with dates specified as an array
    Given a listing in Auckland exists with 1 desks available for the next 1 days
    And a listing in Wellington exists with 1 desks available for the next 7 days
    When I send a search request with a bounding box around New Zealand available 2, 3, and 5 days from now
    Then the response does include the listing in Wellington
    Then the response does not include the listing in Auckland
