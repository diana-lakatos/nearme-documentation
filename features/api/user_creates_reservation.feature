Feature: User creates reservation

  Scenario: Creating a reservation that requires confirmation by the listing owner
    Given I am an authenticated api user
    And a listed location in San Francisco that does require confirmation
    When I send an authenticated POST request to "listings/:id/reservation":
    """
    {
      "dates": [ "<%= 1.week.from_now.monday.to_s %>" ],
      "email": "sai@perchard.com",
      "quantity": 1,
      "assignees": [
        { "email": "sai@perchard.com", "name": "Sai Perchard" }
      ]
    }
    """
    Then I receive a response with 200 status code
    And the JSON at "reservation/state" should be "pending"

  Scenario: Creating a reservation that does not require confirmation by the listing owner
    Given I am an authenticated api user
    And a listed location in San Francisco that does not require confirmation
    When I send an authenticated POST request to "listings/:id/reservation":
    """
    {
      "dates": [ "<%= 1.week.from_now.monday.to_s %>" ],
      "email": "sai@perchard.com",
      "quantity": 1,
      "assignees": [
        { "email": "sai@perchard.com", "name": "Sai Perchard" }
      ]
    }
    """
    Then I receive a response with 200 status code
    And the JSON at "reservation/state" should be "confirmed"
