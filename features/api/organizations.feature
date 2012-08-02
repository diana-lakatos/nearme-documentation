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
            "thumb": { "url": "/uploads/thumb_foobear.jpeg" },
            "medium": { "url": "/uploads/medium_foobear.jpeg"},
            "large": { "url": "/uploads/large_foobear.jpeg" },
            "url": "/media/organization/1/logo/foobear.jpeg"
          }
        },
        {
          "id": 2,
          "name": "Lawyers USA",
          "logo": {
            "thumb": { "url": null },
            "medium": { "url": null },
            "large": { "url": null },
            "url": null
          }
        }
      ]
    }
    """
