Feature: As a user of the site
  In order for them to manage guests
  As a user
  I want to view guests

  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a location exists with company: the company, creator: the user
      And a transactable exists with location: the location, creator: the user, confirm_reservations: true

  @javascript
  Scenario: User rejects reservation
    Given a future_unconfirmed_reservation exists with listing: the transactable
    Given I am on the guests page
    And I reject reservation with reason
    Then I should see "You have rejected the reservation. Maybe next time!"

  Scenario: A user will see information about no reservation
    Given a future_confirmed_reservation exists with listing: the transactable
    Given I am on the guests page
    Then I should see "You have no unconfirmed reservations."

  Scenario: A user will see information about no reservation for past reservation
    Given a past_reservation exists with listing: the transactable
    Given I am on the guests page
    Then I should see "You have no unconfirmed reservations."
