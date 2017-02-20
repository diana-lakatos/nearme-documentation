@javascript @fake_payments
Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a transactable

  Background:
    Given a company exists
      And a location exists with company: that company
      And a transactable exists with location: that location, quantity: 10, photos_count: 1, currency: "USD"
      And a user exists

  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given bookings for that transactable do need to be confirmed
    And I am logged in as the user
    When I go to the transactable's page
    And I select to book and review space for:
      | Transactable     | Date             | Quantity |
      | the transactable | next week Monday | 1        |
    Then I should see "This host manually confirms all bookings."
    And the reservation subtotal should show $50
    And the reservation service fee should show $5
    And the reservation total should show $55

  Scenario: Paying manually should not incur a service fee
    Given a location exists with company: that company
    And a transactable exists with location: that location, quantity: 10, currency: "RUB"
    And I am logged in as the user
    When I go to the transactable's page
    And I select to book and review space for:
      | Transactable     | Date             | Quantity |
      | the transactable | next week Monday | 1        |
    Then the reservation total should show $50

  Scenario: Free booking should show 'Free' in place of rates and $0.00 for the total
    Given I am logged in as the user
    And the transactable is free
    When I go to the transactable's page
    Then I should see a free booking module

  Scenario: Booking and paying by credit card via Stripe
     Given I am logged in as the user
       When I book space for:
        | Transactable     | Date             | Quantity |
        | the transactable | next week Monday | 1        |
       Then I should be redirected to bookings page
       Then I should see "credit card will be charged when your reservation is confirmed"
       And reservation should have billing authorization token

  Scenario: Booking and paying by credit card via Paypal
     Given I am logged in as the user
       And a location exists with company: that company
       And a transactable exists with location: that location, quantity: 10, currency: "JPY"
       And a paypal_payment_gateway exists
       When I book space for:
        | Transactable     | Date             | Quantity |
        | the transactable | next week Monday | 1        |
       Then I should be redirected to bookings page
       Then I should see "credit card will be charged when your reservation is confirmed"
       And reservation should have billing authorization token

  Scenario: As an anonymous user I should return to my booking state after logging in
    When I select to book and review space for:
      | Transactable     | Date             | Quantity |
      | the transactable | next week Monday | 2        |
    Then I should be asked to sign up before making a booking
    When I log in to continue booking
    Then I should see the booking confirmation screen for:
      | Transactable     | Date             | Quantity |
      | the transactable | next week Monday | 2        |

  Scenario: Not logged in user is prompted to log in during booking flow
    When I book space as new user for:
      | Transactable     | Date              | Quantity  |
      | the transactable | next week Monday  | 1         |
      | the transactable | next week Tuesday | 1         |
    Then user should have the transactable reserved for 'next week Monday'
    And user should have the transactable reserved for 'next week Tuesday'

  Scenario: Hourly reserved listing can be booked
    Given the transactable is reserved hourly
    And   the transactable has an hourly price of 100.00
    And I am logged in as the user
    When I go to the transactable's page
    And I select to book and review space for:
      | Transactable     | Date             | Quantity | Start | End   |
      | the transactable | next week Monday | 1        | 9:00  | 14:00 |
    Then I should see the booking confirmation screen for:
      | Transactable     | Date             | Quantity | Start | End   |
      | the transactable | next week Monday | 1        | 9:00  | 14:00 |
    And the reservation subtotal should show $500
    And the reservation service fee should show $50
    And the reservation total should show $550
    And I provide reservation credit card details
    When I click to confirm the booking
    Then the user should have a reservation:
      | Transactable     | Date             | Quantity | Start | End   |
      | the transactable | next week Monday | 1        | 9:00  | 14:00 |

    Scenario: User can properly book regular reservation
      Given I am logged in as the user
      Given Extra fields are prepared for booking
       Then I fail to book space for without extra fields:
            | Transactable     | Date         | Quantity  |
            | the transactable | next week Monday  | 1         |
            | the transactable | next week Tuesday | 1         |
       When I book space for with extra fields:
            | Transactable     | Date         | Quantity  |
            | the transactable | next week Monday  | 1         |
            | the transactable | next week Tuesday | 1         |
       Then the user should have the transactable reserved for 'next week Monday'
        And the user should have the transactable reserved for 'next week Tuesday'
        And I should be redirected to bookings page

    Scenario: Booking for a 'automatically confirm' listing should show relevant details
      Given bookings for the transactable do not need to be confirmed
      And I am logged in as the user
      When I go to the transactable's page
      And I select to book and review space for:
        | Transactable     | Date             | Quantity |
        | the transactable | next week Monday | 1        |
      Then I should not see "This host manually confirms all bookings before payment"
