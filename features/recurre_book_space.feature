@javascript
Feature: A user can recurre book at a space
  In order to have a place to work
  As a user
  I want to recurre book a transactable

  Background:
    Given a company exists
      And a location exists with company: that company, currency: "USD"
      And a transactable exists with location: that location, quantity: 10
      And a user exists with name: "John Doe"
      And recurre booking is enabled

  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given bookings for that transactable do need to be confirmed
    And I am logged in as the user
    When I go to the location's page
    And I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 1        |
    Then I should see "This host manually confirms all bookings."
    And the reservation subtotal should show $50.00
    And the reservation service fee should show $5.00
    And the reservation total should show $55.00

  Scenario: Paying manually should not incur a service fee
    Given a location exists with company: that company, currency: "RUB"
    And a transactable exists with location: that location, quantity: 10
    And I am logged in as the user
    When I go to the location's page
    And I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 1        |
    Then the reservation total should show $50.00

  Scenario: Free booking should show 'Free' in place of rates and $0.00 for the total
    Given I am logged in as the user
    And a location exists with company: that company, currency: "USD"
    And a transactable exists with location: that location, quantity: 10, daily_price_cents: nil, free: true
    When I go to the location's page
    Then I should see a free booking module

  Scenario: Booking and paying by credit card via Stripe
    Given I am logged in as the user
    When I go to the location's page
    And  I recurre book space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 1        |
    And  I follow "Manage"
    Then I should be redirected to recurring bookings page
    And  I should see "credit card will be charged when your reservation is confirmed"
    And  the user should have a billing profile

  Scenario: As an anonymous user I should be asked to sign up before booking
    When I go to the location's page
    When I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 1        |
    Then I should be asked to sign up before making a booking

  Scenario: As an anonymous user I should return to my booking state after logging in
    When I go to the location's page
    When I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 2        |
    And I log in to continue booking
    Then I should see the recurring booking confirmation screen for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 2        |

  Scenario: As an anonymous user I should return to my booking state after signing up
    When I go to the location's page
    When I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 2        |
    And I sign up as a user in the modal
    Then I should see the recurring booking confirmation screen for:
      | Transactable     | Start On   | End On                  | Quantity |
      | the transactable | Monday     | 14 days from now Friday | 2        |

  Scenario: Hourly reserved listing can be booked
    Given the transactable is reserved hourly
    And   the transactable has an hourly price of 100.00
    And I am logged in as the user
    When I go to the location's page
    And I select to recurre book and review space for:
      | Transactable     | Start On   | End On                  | Quantity | Start | End   |
      | the transactable | Monday     | 14 days from now Friday | 2        | 9:00  | 14:00 |
    Then I should see the recurring booking confirmation screen for:
      | Transactable     | Start On   | End On                  | Quantity | Start | End   |
      | the transactable | Monday     | 14 days from now Friday | 2        | 9:00  | 14:00 |
    And the reservation subtotal should show $1,000.00
    And the reservation service fee should show $100.00
    And the reservation total should show $1,100.00
    And I provide reservation credit card details
    When I click to confirm the booking
    Then the user should have a recurring booking:
      | Transactable     | Start On   | End On                  | Quantity | Start | End   |
      | the transactable | Monday     | 14 days from now Friday | 2        | 9:00  | 14:00 |

