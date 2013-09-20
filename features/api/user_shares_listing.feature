@listing_emails
Feature: User shares listing

  Scenario: Success
    Given I am an authenticated api user
    And a listed location
    When I send an authenticated POST request to "listings/:id/share":
    """
    {
      "to": [
        { "name": "John Carter", "email": "john@example.com" },
        { "name": "Dejah Thoris", "email": "dejah@example.com" }
      ],
      "message": "You guys, you should check this out! Seriously cool!"
    }
    """
    Then I receive a response with 204 status code
    And a shared listing email is sent to "john@example.com"
    And a shared listing email is sent to "dejah@example.com"

  Scenario: Unauthenticated
    Given a listed location
    When I send a POST request to "listings/:id/share":
    """
    {
      "to": [
        { "name": "John Carter", "email": "john@example.com" },
        { "name": "Dejah Thoris", "email": "dejah@example.com" }
      ],
      "message": "You guys, you should check this out! Seriously cool!"
    }
    """
    Then I receive a response with 401 status code
    And a shared listing email is not sent to "john@example.com"
    And a shared listing email is not sent to "dejah@example.com"
