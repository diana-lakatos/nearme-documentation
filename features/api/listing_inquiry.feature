Feature: User Inquires about Listing

  Scenario: Sending an inquiry
    Given I am an authenticated api user
    And a listed location
    When I send an authenticated POST request to "listings/:id/inquiry":
    """
    {
      "message": "Hi, could you tell me more about the WiFi here?"
    }
    """
    Then I receive a response with 204 status code