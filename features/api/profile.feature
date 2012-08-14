@api
Feature: Profile

  Scenario: GET /profile
    Given I am an authenticated api user and my name is User-1
    When I send an authenticated GET request for "profile"
    Then the JSON should be:
    """
    {
      "user": {
        "id": 1,
        "name": "User-1",
        "email": "user_1@example.com",
        "phone": "1234567890",
        "avatar": {}
      }
    }
    """