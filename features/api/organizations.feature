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
          "logo": {
            "thumb": { "url": "/media/organization/1/logo/thumb_foobear.jpeg" },
            "medium": { "url": "/media/organization/1/logo/medium_foobear.jpeg"},
            "large": { "url": "/media/organization/1/logo/large_foobear.jpeg" },
            "url": "/media/organization/1/logo/foobear.jpeg"
          }
        },
        {
          "id": 2,
          "name": "Lawyers USA",
          "logo": {
            "thumb": { "url": "http://placehold.it/100x100" },
            "medium": { "url": "http://placehold.it/100x100" },
            "large": { "url": "http://placehold.it/100x100" },
            "url": "http://placehold.it/100x100"
          }
        }
      ]
    }
    """
