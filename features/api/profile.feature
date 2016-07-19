@api
Feature: Profile

  Scenario: GET /profile
    Given I am an authenticated api user and my name is User-1 LastName and my email is user_123@example.com
    When I send an authenticated GET request for "profile"
    Then the JSON should be:
    """
    {
      "user": {
        "id": 1,
        "name": "User-1 LastName",
        "email": "user_123@example.com",
        "phone": "18889983375",
        "avatar": {}
      }
    }
    """
