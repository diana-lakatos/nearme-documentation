Feature: User Searches Listings

  @wip
  Scenario: Searching for everything
    Given a listing in San Francisco
    And a listing in Cleveland
    And a listing in Auckland
    When I send a POST request to "listings/search":
    """
    {
      "boundingbox": {"start": {"lat": -180.0,"lon": -180.0}, "end": {"lat": 180.0,"lon": 180.0 }}
    }
    """
    Then the JSON should be:
    """
    {
      "listings": {
        "id": 1,
        "name": "Auckland Meuseum",
        "address": "Parnell, Auckland 1010 New Zealand"
      }
    }
    """



  Scenario: Searching by amenities
    Given a listed location with an amenity with the id of 1
    And a listed location without amenities
    When I send a POST request to "listings/search":
    """
    {
      "boundingbox": {"start": {"lat": -180.0,"lon": -180.0}, "end": {"lat": 180.0,"lon": 180.0 }},
      "amenities": [1]
    }
    """
    Then I receive only listings which have that amenity

  Scenario: Searching by organization
    Given a listed location with an organization with the id of 1
    And a listed location without organizations
    When I send a POST request to "listings/search":
    """
    {
      "boundingbox": {"start": {"lat": -180.0,"lon": -180.0}, "end": {"lat": 180.0,"lon": 180.0 }},
      "organizations": [1]
    }
    """
    Then I receive only listings which have that organization
