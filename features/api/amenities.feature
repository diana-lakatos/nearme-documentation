@api
Feature: List amenities
  In order to discover the amenities
  As an API client
  I want to list amenities

  Scenario: GET /amenities
    Given an amenity named WiFi Internet
      And an amenity named Coffee Machine
     When I send a GET request for "amenities"
     Then the JSON should be:
    """
    {
      "amenities": [
        {
        "id": 1,
        "amenity_type_id": 1,
        "name": "WiFi Internet"
        },
        {
        "id": 2,
        "amenity_type_id": 2,
        "name": "Coffee Machine"
        }
      ]
    }
    """
