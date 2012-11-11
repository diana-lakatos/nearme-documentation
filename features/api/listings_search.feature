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
    When I send a search request with a bounding box around New Zealand with that organization
    Then the response should have the listing in Auckland with the lowest score
    Then the response should have the listing in Wellington with the highest score

  @wip
  Scenario: Searching for a listing using availability parameters
    Given a listing in Auckland exists with 5 desks available for the next 7 days
    And a listing in Wellington exists with 10 desks available for the next 7 days
    And the Sphinx indexes are updated
    When I send a POST request to "listings/search":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "boundingbox": {"start": {"lat": -32.24997,"lon": 162.94921 }, "end": {"lat": -47.04018,"lon": 180.00000 }},
      "quantity": {"min": 7 },
      "dates": { "start" : "<%= 2.days.from_now.to_date %>", "end" : "<%= 5.days.from_now.to_date %>" }
    }
    """
    Then the JSON should be:
    """
    {
      "listings": [
        {
          "address": "Parnell, Auckland 1010 New Zealand",
          "amenities": [

          ],
          "company_description": "Aliquid eos ab quia officiis sequi.",
          "company_name": "Company in Auckland",
          "description": "Aliquid eos ab quia officiis sequi.",
          "lat": -36.858675,
          "lon": 174.777303,
          "name": "Listing in Auckland",
          "organizations": [

          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 5,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 47.5,
          "strict_match": false
        },
        {
          "address": "35 Ghuznee Street",
          "amenities": [

          ],
          "company_description": "Aliquid eos ab quia officiis sequi.",
          "company_name": "Company in Wellington",
          "description": "Aliquid eos ab quia officiis sequi.",
          "lat": -41.293597,
          "lon": 174.7763361,
          "name": "Listing in Wellington",
          "organizations": [

          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 10,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 27.5,
          "strict_match": true
        }
      ]
    }
    """

  Scenario: Searching for a listing using availability parameters and dates specified as an array
    Given a listing in Auckland exists with 5 desks available for the next 7 days
    And a listing in Wellington exists with 10 desks available for the next 7 days
    And the Sphinx indexes are updated
    When I send a POST request to "listings/search":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "boundingbox": {"start": {"lat": -32.24997,"lon": 162.94921 }, "end": {"lat": -47.04018,"lon": 180.00000 }},
      "quantity": {"min": 7 },
      "dates": [ "<%= 2.days.from_now.to_date %>", "<%= 3.days.from_now.to_date %>", "<%= 5.days.from_now.to_date %>" ]
    }
    """
    Then the JSON should be:
    """
    {
      "listings": [
        {
          "address": "Parnell, Auckland 1010 New Zealand",
          "amenities": [

          ],
          "company_description": "Aliquid eos ab quia officiis sequi.",
          "company_name": "Company in Auckland",
          "description": "Aliquid eos ab quia officiis sequi.",
          "lat": -36.858675,
          "lon": 174.777303,
          "name": "Listing in Auckland",
          "organizations": [

          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 5,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 47.5,
          "strict_match": false
        },
        {
          "address": "35 Ghuznee Street",
          "amenities": [

          ],
          "company_description": "Aliquid eos ab quia officiis sequi.",
          "company_name": "Company in Wellington",
          "description": "Aliquid eos ab quia officiis sequi.",
          "lat": -41.293597,
          "lon": 174.7763361,
          "name": "Listing in Wellington",
          "organizations": [

          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 10,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 27.5,
          "strict_match": true
        }
      ]
    }
    """

  Scenario: Searching for a listing that requires organization membership to be visible (a "private" listing) when I am not authenicated
    Given a listing with name "Secret Cave of Awesome" exists for a location with a private organization
    And the Sphinx indexes are updated
    And I am not an authenticated api user
    When I send a POST request to "listings/query":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "query": "Cave of Awesome"
    }
    """
    Then the JSON listings should be empty

  Scenario: Searching for a listing that requires organization membership to be visible (a "private" listing)
    Given a listing with name "Secret Cave of Awesome" exists for a location with a private organization
    And the Sphinx indexes are updated
    And I am an authenticated api user
    And I am a member of the above organization
    When I send an authenticated POST request to "listings/query":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "query": "Cave of Awesome"
    }
    """
    Then the JSON should contain that listing
