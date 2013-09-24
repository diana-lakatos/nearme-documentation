@inquiry_emails
Feature: User Inquires about Listing

  Scenario: Sending an inquiry
    Given I am an authenticated api user and my email is nik@desksnear.me
    And a listed location with a creator whose email is jared@desksnear.me
    When I send an authenticated POST request to "listings/:id/inquiry":
    """
    {
      "message": "Hi, could you tell me more about the WiFi here?"
    }
    """
    Then I receive a response with 204 status code
    And an inquiry user notification email is sent to "nik@desksnear.me"
    And an inquiry creator notification email is sent to "jared@desksnear.me"

