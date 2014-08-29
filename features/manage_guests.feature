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

  Scenario: User rejects reservation
    Given a reservation exists with listing: the transactable
    Given I am on the manage guests dashboard page
    And I reject reservation with reason
    Then I should see "You have rejected the reservation. Maybe next time!"

  Scenario: A user will see information about no reservation
    Given a reservation exists with listing: the transactable, state: "confirmed"
    Given I am on the manage guests dashboard page
    Then I should see "You have no unconfirmed reservations."
