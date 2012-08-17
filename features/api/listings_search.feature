Feature: User Searches Listings

  Scenario: Searching for everything
    Given a listing in San Francisco exists
    And a listing in Cleveland exists
    And a listing in Auckland exists
    When I send a POST request to "listings/search":
    """
    {
      "boundingbox": {"start": {"lat": -180.0,"lon": -180.0}, "end": {"lat": 180.0,"lon": 180.0 }}
    }
    """
    Then the JSON should be:
    """
    {
      "listings": [
      {
        "address": "Golden Gate Bridge",
          "amenities": [

            ],
          "company_description": "Aliquid eos ab quia officiis sequi.",
          "company_name": "Company in San Francisco",
          "description": "Aliquid eos ab quia officiis sequi.",
          "lat": 37.819959,
          "lon": -122.478696,
          "name": "Listing in San Francisco",
          "organizations": [

            ],
          "photos": [

            ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00"
          },
          "quantity": 1,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 50.0
      },
      {
        "address": "1100 Rock and Roll Boulevard",
        "amenities": [

          ],
        "company_description": "Aliquid eos ab quia officiis sequi.",
        "company_name": "Company in Cleveland",
        "description": "Aliquid eos ab quia officiis sequi.",
        "lat": 41.508806,
        "lon": -81.69548,
        "name": "Listing in Cleveland",
        "organizations": [

          ],
        "photos": [

          ],
        "price": {
          "amount": 50.0,
          "currency_code": "USD",
          "label": "$50.00"
        },
        "quantity": 1,
        "rating": {
          "average": 0.0,
          "count": 0
        },
        "score": 50.0
      },
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
          "label": "$50.00"
        },
        "quantity": 1,
        "rating": {
          "average": 0.0,
          "count": 0
        },
        "score": 50.0
      }
      ]
    }
    """

  Scenario: Searching by organization
    Given a listed location without organizations
    And a listed location with an organization
    When I search for listings with that organization
    Then I receive only listings which have that organization
