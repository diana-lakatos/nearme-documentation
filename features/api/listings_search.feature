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
        "associations": [

          ],
        "photos": [

          ],
        "price": {
          "amount": 50.0,
          "period": "day",
          "currency_code": "USD",
          "label": "$50.00"
        },
        "quantity": 1,
        "rating": {
          "average": 0.0,
          "count": 0
        },
        "score": 40.0,
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
         "amenities": [ 123 ],
         "company_description": "Aliquid eos ab quia officiis sequi.",
         "company_name": "Company in Auckland",
         "description": "Aliquid eos ab quia officiis sequi.",
         "lat": -36.858675,
         "lon": 174.777303,
         "name": "Listing in Auckland",
         "associations": [

         ],
         "photos": [

         ],
         "price": {
           "amount": 150.0,
           "period": "day",
           "currency_code": "USD",
           "label": "$150.00"
         },
         "quantity": 1,
         "rating": {
           "average": 0.0,
           "count": 0
         },
         "score": 62.5,
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
         "associations": [

         ],
         "photos": [

         ],
         "price": {
           "amount": 250.0,
           "period": "day",
           "currency_code": "USD",
           "label": "$250.00"
         },
         "quantity": 1,
         "rating": {
           "average": 0.0,
           "count": 0
         },
         "score": 42.5,
         "strict_match": false
       }
     ]
   }
   """

  Scenario: Searching for some listings with organizations
    Given an organization exists
    And a listing in Auckland exists which is a member of that organization
    And a listing in Wellington exists which is NOT a member of that organization
    And the Sphinx indexes are updated
    When I send a POST request to "listings/search":
    # NB this is a bounding box around New Zealand :)
    """
    {
      "boundingbox": {"start": {"lat": -32.24997,"lon": 162.94921 }, "end": {"lat": -47.04018,"lon": 180.00000 }},
      "associations": [ <%= model!("organization").id %> ]
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
          "associations": [
            {
              "icon": {
                "large_url": "http://placehold.it/100x100",
                "medium_url": "http://placehold.it/100x100",
                "thumb_url": "http://placehold.it/100x100"
              },
              "name": "Organization 1"
            }
          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 1,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 40.0,
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
          "associations": [

          ],
          "photos": [

          ],
          "price": {
            "amount": 50.0,
            "currency_code": "USD",
            "label": "$50.00",
            "period": "day"
          },
          "quantity": 1,
          "rating": {
            "average": 0.0,
            "count": 0
          },
          "score": 20.0,
          "strict_match": false
        }
      ]
    }
    """

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
          "associations": [

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
          "associations": [

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
          "associations": [

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
          "associations": [

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