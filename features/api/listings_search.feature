Feature: User Searches Listings

  Scenario: Searching for a listing with a bounding box
    Given a listing in San Francisco exists
    And a listing in Cleveland exists
    And a listing in Auckland exists
    And the Sphinx indexes are updated
    When I send a POST request to "listings/search":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "boundingbox": {"start": {"lat": -32.24997,"lon": 162.94921 }, "end": {"lat": -47.04018,"lon": 180.00000 }}
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
          "label": "$50.00"
        },
        "quantity": 1,
        "rating": {
          "average": 0.0,
          "count": 0
        },
        "score": 0.0,
        "strict_match": true
      }
      ]
    }
    """

  Scenario: Searching for some listings with a few price parameters
    Given a Wi-Fi amenity
    And a listing in Auckland exists with a price of $150.00 and Wi-Fi
    And a listing in Wellington exists with a price of $250.00
    And the Sphinx indexes are updated
    When I send a POST request to "listings/search":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "boundingbox": {"start": {"lat": -32.24997,"lon": 162.94921 }, "end": {"lat": -47.04018,"lon": 180.00000 }},
      "price": {"min": 100, "max": 1000},
      "amenities": [ 123 ]
    }
    """
    Then the JSON should be:
    """
    {
      "listings": [
       {
         "address": "Parnell, Auckland 1010 New Zealand",
         "amenities": [
           {
             "name": "Wi-Fi"
           }
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
           "amount": 150.0,
           "currency_code": "USD",
           "label": "$150.00"
         },
         "quantity": 1,
         "rating": {
           "average": 0.0,
           "count": 0
         },
         "score": 22.5,
         "strict_match": true
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
           "amount": 250.0,
           "currency_code": "USD",
           "label": "$250.00"
         },
         "quantity": 1,
         "rating": {
           "average": 0.0,
           "count": 0
         },
         "score": 22.5,
         "strict_match": false
       }
     ]
   }
   """

  # Scenario: Searching by organization
  #   Given a listed location with an organization with the id of 1
  #   And a listed location without organizations
  #   When I send a POST request to "listings/search":
  #   """
  #   {
  #     "boundingbox": {"start": {"lat": -180.0,"lon": -180.0}, "end": {"lat": 180.0,"lon": 180.0 }},
  #     "organizations": [1]
  #   }
  #   """
  #   Then I receive only listings which have that organization
