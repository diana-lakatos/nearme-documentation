Feature: User Searches Listings

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
