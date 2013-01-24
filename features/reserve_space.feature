Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a listing

  Background:
    Given a company exists
      And a location exists with company: that company
      And a listing exists with location: that location, quantity: 10
      And a user exists

  @javascript @borked
  Scenario: A logged in user can book a listing
    Given I am logged in as the user
      When I book space for:
          | Listing     | Date   | Quantity  |
          | the listing | Monday  | 1        |
          | the listing | Tuesday | 1        |
     Then the user should have the listing reserved for 'Monday'
      And the user should have the listing reserved for 'Tuesday'

  @javascript @borked
  Scenario: Booking for a 'automatically confirm' listing should show relevant details
    Given I am logged in as the user
    And bookings for the listing do not need to be confirmed
    When I go to the location's page
    And I book space for:
      | Listing | Date | Quantity|
      | the listing | Monday | 1 |
    And I click to review the booking
    Then I should see "This host manually confirms all bookings before payment"

  @javascript @borked
  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given I am logged in as the user
    And bookings for that listing do need to be confirmed
    When I go to the location's page
    And I book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    And I click to review the booking
    Then I should not see "This host manually confirms all bookings before payment"
