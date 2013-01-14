Feature: Emails should be sent out informing parties about reservations
  In order to know or change the status of a reservation
  As a user or listing owner
  I want to receive emails updating me about the status of my reservations

  Background:
    Given a user: "Keith Contractor" exists with name: "Keith Contractor", email: "keith@example.com"
    And a user: "Bo Jeanes" exists with name: "Bo Jeanes", email: "bo@example.com"

  @javascript
  Scenario: reservation confirmations required (no comment)
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And I am logged in as user "Keith Contractor"
    When I book space for:
      | Listing     | Date | Quantity|
      | the listing | Monday | 1 |
    Then a confirm reservation email should be sent to bo@example.com
    And a reservation awaiting confirmation email should be sent to keith@example.com

  @javascript
  Scenario: reservation confirmations not required
    Given a listing: "Mocra" exists with creator: user "Bo Jeanes", confirm_reservations: false
    And I am logged in as user "Keith Contractor"
    When I book space for:
      | Listing     | Date | Quantity|
      | the listing | Monday | 1 |
    Then a reservation confirmed email should be sent to keith@example.com
    Then a new reservation email should be sent to bo@example.com

  @borked @javascript
  Scenario: reservation gets confirmed
    Given Bo Jeanes has a listing with an unconfirmed reservation for Keith Contractor
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15"
    And I am logged in as user "Bo Jeanes"
    When I confirm the reservation
    Then a reservation confirmed email should be sent to keith@example.com

  @borked @javascript
  Scenario: confirmed then cancelled by user
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "confirmed"
    And all emails have been delivered
    And I am logged in as user "Keith Contractor"
    When I cancel the reservation
    Then a reservation cancelled email should be sent to bo@example.com

  @borked
  @javascript
  Scenario: confirmed then cancelled by owner
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "confirmed"
    And all emails have been delivered
    And I am logged in as user "Bo Jeanes"
    When I cancel the reservation
    Then a reservation cancelled by owner email should be sent to keith@example.com

  @borked
  @javascript
  Scenario: unconfirmed reservation gets cancelled by user
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "unconfirmed"
    And all emails have been delivered
    And I am logged in as user "Keith Contractor"
    When I cancel the reservation
    Then a reservation cancelled email should be sent to bo@example.com

  @borked
  @javascript
  Scenario: unconfirmed reservation gets rejected
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "unconfirmed"
    And all emails have been delivered
    And I am logged in as user "Bo Jeanes"
    When I reject the reservation
    Then 1 email should be delivered
    And the email should be delivered to user "Keith Contractor"
    And the email should have subject: "[Desks Near Me] Sorry, your reservation at Mocra has been rejected"
