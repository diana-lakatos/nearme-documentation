@javascript
Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a listing

  Background:
    Given a company exists
      And a location exists with company: that company, currency: "CAD"
      And a listing exists with location: that location, quantity: 10
      And a user exists

  Scenario: A logged in user can book a listing
    Given I am logged in as the user
      When I book space for:
          | Listing     | Date         | Quantity  |
          | the listing | next Monday  | 1         |
          | the listing | next Tuesday | 1         |
     Then the user should have the listing reserved for 'next Monday'
      And the user should have the listing reserved for 'next Tuesday'

  Scenario: Booking for a 'automatically confirm' listing should show relevant details
    Given bookings for the listing do not need to be confirmed
    And I am logged in as the user
    When I go to the location's page
    And I select to book and review space for:
      | Listing | Date | Quantity|
      | the listing | Monday | 1 |
    Then I should not see "This host manually confirms all bookings before payment"

  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given bookings for that listing do need to be confirmed
    And I am logged in as the user
    When I go to the location's page
    And I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    Then I should see "This host manually confirms all bookings before payment"
    And the reservation subtotal should show $50.00
    And the reservation service fee should show $5.00
    And the reservation total should show $55.00

  Scenario: Paying manually should not incur a service fee
    Given I am logged in as the user
    When I go to the location's page
    And I select to book and review space for:
      | Listing | Date | Quantity|
      | the listing | Monday | 1 |
    When I choose to pay manually
    Then the reservation total should show $50.00

  Scenario: Booking and paying by credit card
     Given I am logged in as the user
       When I book space with credit card for:
        | Listing     | Date   | Quantity |
        | the listing | Monday | 1        |
       Then I should see "credit card will be charged when your reservation is confirmed"
       And the user should have a billing profile

  Scenario: As an anonymous user I should be asked to sign up before booking
    When I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |
    Then I should be asked to sign up before making a booking

  Scenario: As an anonymous user I should return to my booking state after logging in
    When I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |
    And I log in to continue booking
    Then I should see the booking confirmation screen for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |

  Scenario: As an anonymous user I should return to my booking state after signing up
    When I select to book and review space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |
    And I sign up as a user in the modal
    Then I should see the booking confirmation screen for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 2        |

  Scenario: Not logged in user is prompted to log in during booking flow
     When I book space as new user for:
          | Listing     | Date         | Quantity  |
          | the listing | next Monday  | 1         |
          | the listing | next Tuesday | 1         |
     Then user should have the listing reserved for 'next Monday'
      And user should have the listing reserved for 'next Tuesday'

  Scenario: Hourly reserved listing can be booked
    Given the listing is reserved hourly
    And   the listing has an hourly price of 100.00
    And I am logged in as the user
    When I go to the location's page
    And I select to book and review space for:
      | Listing     | Date   | Quantity | Start | End   |
      | the listing | Monday | 1        | 9:00  | 14:00 |
    Then I should see the booking confirmation screen for:
      | Listing     | Date   | Quantity | Start | End   |
      | the listing | Monday | 1        | 9:00  | 14:00 |
    And the reservation subtotal should show $500.00
    And the reservation service fee should show $50.00
    And the reservation total should show $550.00
    When I click to confirm the booking
    Then the user should have a reservation:
      | Listing     | Date   | Quantity | Start | End   |
      | the listing | Monday | 1        | 9:00  | 14:00 |

  Scenario: User sees booking confirmation details after successful reservation
    Given I am logged in as the user
     When I book space for:
          | Listing     | Date         | Quantity  |
          | the listing | next Monday  | 1         |
          | the listing | next Tuesday | 1         |
     Then I should be redirect to bookings page

  Scenario: Last bookings is highlighted
    Given I am logged in as the user
     When I book space for:
          | Listing     | Date         | Quantity  |
          | the listing | next Monday  | 1         |
          | the listing | next Tuesday | 1         |
     When I book space for:
          | Listing     | Date         | Quantity  |
          | the listing | next Wednesday  | 1      |
     Then The second booking should be highlighted
