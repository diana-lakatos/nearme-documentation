Feature: As a user of the site
  In order for them to manage guests
  As a user
  I want to view guests

  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a location exists with company: the company, creator: the user, street: "Rad Annex House"
      And a location exists with company: the company, creator: the user, street: "Annex Red House"
      And a listing exists with location: the location, creator: the user, name: "Rad Annex", confirm_reservations: true

  Scenario: A user will see tweet links for locations from the first company
    Given the user has second company with location "Second location"
     When I am on the manage guests dashboard page
     Then I should see "Rad Annex House"
      And I should see "Annex Red House"
      And I should not see "Second location"

  Scenario: User rejects reservation
    Given a reservation exists with listing: the listing
    Given I am on the manage guests dashboard page
    And I reject reservation with reason
    Then I should see "You have rejected the reservation. Maybe next time!" 

  Scenario: A user will see information about no reservation
    Given a reservation exists with listing: the listing, state: "confirmed"
    Given I am on the manage guests dashboard page
    Then I should see "You have no unconfirmed reservations. Have a nice day!"
