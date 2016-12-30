@javascript
Feature: A user can subscribe to a service
  In order to become subscriber
  As a user
  I want to subscribe to a service

  Background:
    Given a user exists
      And the company exists with creator: the user
      And a location exists with company: that company
      And a transactable_type_subscription exists
      And a subscription_transactable exists with transactable_type: transactable_type_subscription, location: the location

  Scenario: Subscribing to a service should succeed
    Given I am logged in as the user
      And I go to the transactable's page
     When I subscribe to the service
     Then I am subscribed to the service
     Then I should see all text:
        |Your reservation has been made!                                                 |
        |Pending confirmation from host. Booking will expire in 23 hours                 |
        |Unconfirmed                                                                     |

  Scenario: Host subscription flow walk through
    Given a activated_recurring_booking exists with user: the user, transactable: subscription_transactable
      And I am logged in as the user
     When I go to unconfirmed subscriptions page
     Then I should see all text:
        |You must confirm this booking|
        |Unconfirmed                  |
        |Reservation placed           |
        |Next payment                 |
     When I confirm the subscription
     Then I should see all text:
        |You have no unconfirmed reservations.|
        |You have confirmed the reservation  |
     When I go to confirmed subscriptions page
     Then I should see all text:
        |booked     |
        |Confirmed  |
        |Paid until |
        |Periods    |
     When I cancel the subscription
     Then I should see all text:
        |You have cancelled this reservation.|
     When I go to archived subscriptions page
     Then I should see all text:
        |Cancelled by host|
        |Paid until       |

  Scenario: Guest unconfiremd subscription cancel
    Given a activated_recurring_booking exists with user: the user, transactable: subscription_transactable
      And I am logged in as the user
     When I go to my unconfirmed subscriptions page
      And I cancel the subscription
     Then I should see all text:
       |You have cancelled your reservation.    |
       |You don't have any orders yet           |
     When I go to my archived subscriptions page
     Then I should see all text:
       |Cancelled by guest|

  Scenario: Guest confirmed subscription cancel
    Given a confirmed_recurring_booking exists with user: the user, transactable: subscription_transactable
      And I am logged in as the user
     When I go to my subscriptions page
      And I cancel the subscription
     Then I should see all text:
       |You have cancelled your reservation.    |
       |You don't have any orders yet           |
     When I go to my archived subscriptions page
     Then I should see all text:
       |Cancelled by guest|



