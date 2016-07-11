@javascript
Feature: User can complete reservation and provide time log and additional charges
  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a always_open_location exists with company: the company, creator: the user
      And a listing_with_10_dollars_per_hour_and_24h exists with location: the always_open_location, creator: the user, confirm_reservations: true
      And transactable type skips payment authorization initially

  Scenario: User adds 2 time logs and one additional charge
    Given a confirmed_hour_reservation exists with listing: the listing_with_10_dollars_per_hour_and_24h
    Given I am on the confirmed reservations
    And I follow "Complete reservation"
    And I follow "add_new_period"
    And I fill in a time log fields
    And I follow "add_new_additional_charge"
    And I follow "add_new_additional_charge"
    And I delete last additional charge
    And I fill in a additional charge fields
    Then I should see correct Total cost of "$160.00"
    When I press "Submit invoice"
    Then I should see "You have completed your reservation and the invoice details have been submitted"
    And reservation should have all data stored

  Scenario: User can't save the reservation if don't fill all fields
    Given a confirmed_hour_reservation exists with listing: the listing_with_10_dollars_per_hour_and_24h
    Given I am on the confirmed reservations
    And I follow "Complete reservation"
    And I follow "add_new_period"
    And I follow "add_new_additional_charge"
    And I fill in a additional charge fields
    Then I should see correct Total cost of "$120.00"
    When I press "Submit invoice"
    Then I should see "Your invoice details couldn't be saved"
    And I fill in a time log fields
    Then I should see correct Total cost of "$160.00"
    When I press "Submit invoice"
    Then I should see "You have completed your reservation and the invoice details have been submitted"
