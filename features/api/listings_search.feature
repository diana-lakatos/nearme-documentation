Feature: User Searches Listings
  Scenario: Searching for a listing with a bounding box
    Given a listing in San Francisco exists
    And a listing in Cleveland exists
    And a listing in Auckland exists
    When I send a search request with a bounding box around New Zealand
    Then the response does include the listing in Auckland
    And the response does not include the listing in San Francisco
    And the response does not include the listing in Cleveland

  Scenario: Searching for some listings with a few price parameters
    Given a listing in Auckland exists with a price of $150.00
    And a listing in Wellington exists with a price of $250.00
    When I send a search request with a bounding box around New Zealand and prices between $0 and $200
    Then the response should have the listing in Auckland with the lowest score
    Then the response should have the listing in Wellington with the highest score

  Scenario: Searching for some listings with organizations
    Given an organization exists
    And a listing in Auckland exists which is a member of that organization
    And a listing in Wellington exists which is NOT a member of that organization
    When I send a search request with a bounding box around New Zealand and that organization
    Then the response should have the listing in Auckland with the lowest score
    Then the response should have the listing in Wellington with the highest score

  Scenario: Searching for a listing with a minimum amount of desks
    Given a listing in Auckland exists with 5 desks available for the next 7 days
    And a listing in Wellington exists with 10 desks available for the next 7 days
    When I send a search request with a bounding box around New Zealand and a minimum of 7 desks
    Then the response should have the listing in Wellington with the lowest score
    Then the response should have the listing in Auckland with the highest score

  Scenario: Searching for a listing with dates specified as an array
    Given a listing in Auckland exists with 1 desks available for the next 1 days
    And a listing in Wellington exists with 1 desks available for the next 7 days
    When I send a search request with a bounding box around New Zealand available 2, 3, and 5 days from now
    Then the response should have the listing in Wellington with the lowest score
    Then the response should have the listing in Auckland with the highest score

  @wip
  Scenario: Searching for a listing that requires organization membership to be visible when not authenicated
    Given a listing in Auckland exists for a location with a private organization
    When I send a search request with a bounding box around New Zealand
    Then the JSON listings should be empty

  @wip
  Scenario: Searching for a listing that requires organization membership to be visible when authenicated
    Given a listing in Auckland exists for a location with a private organization
    And I am a member of that organization
    When I send an authenticated search request with a bounding box around New Zealand
    Then the JSON should contain that listing
