Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a listing

  Background:
    Given a company exists
      And a location exists with company: that company
      And a listing exists with location: that location, quantity: 10
      And a user exists
      And I am logged in as the user

  @javascript
  Scenario: A logged in user can book a listing
      When I book space for:
          | Listing     | Date   | Quantity  |
          | the listing | Monday  | 1        |
          | the listing | Tuesday | 1        |
     Then the user should have the listing reserved for 'Monday'
      And the user should have the listing reserved for 'Tuesday'

  @javascript
  Scenario: Booking for a 'automatically confirm' listing should show relevant details
    Given bookings for the listing do not need to be confirmed
    When I go to the location's page
    And I book space for:
      | Listing | Date | Quantity|
      | the listing | Monday | 1 |
    And I click to review the booking
    Then I should see "This host manually confirms all bookings before payment"

  @javascript
  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given bookings for that listing do need to be confirmed
    When I go to the location's page
    And I book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    And I click to review the booking
    Then I should not see "This host manually confirms all bookings before payment"

  @javascript
  Scenario: As an anonymous user I should be asked to log in before booking
    Given I am not logged in
    When I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |
    Then I should be asked to log in before making a booking

  @javascript
  Scenario: As an anonymous user I should return to my booking state after logging in
    Given I am not logged in
    When I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |
    And I log in to continue booking
    Then I should see the booking confirmation screen for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |    



