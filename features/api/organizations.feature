Feature: List organizations
  In order to discover the organizations
  As an API client
  I want to list organizations

  Scenario: GET /organizations
    Given an organization with logo named AICPA
    And an organization named Lawyers USA
    When I send a GET request for "organizations"
    Then the JSON should be:
    """
    {
      "organizations": [
        {
          "id": 3,
          "name": "AICPA",
          "icon": {
            "large_url": "/media/organization/4/logo/large_foobear.jpeg",
            "medium_url": "/media/organization/4/logo/medium_foobear.jpeg",
            "thumb_url": "/media/organization/4/logo/thumb_foobear.jpeg"
          }
        },
        {
          "id": 2,
          "name": "Lawyers USA",
          "icon": {
           "large_url": "http://placehold.it/100x100",
           "medium_url": "http://placehold.it/100x100",
           "thumb_url": "http://placehold.it/100x100"
          }
        }
      ]
    }
    """
