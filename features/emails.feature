Feature: Emails should be sent out informing parties about reservations
  In order to know or change the status of a reservation
  As a user or listing owner
  I want to receive emails updating me about the status of my reservations

  Background:
    Given a user: "Keith Contractor" exists with name: "Keith Contractor", email: "keith@example.com"
    And a user: "Bo Jeanes" exists with name: "Bo Jeanes", email: "bo@example.com"

  @javascript
  Scenario: reservation confirmations required (no comment)
    Given Bo Jeanes does require confirmation for his listing
    When Keith Contractor books a space for that listing
    Then a confirm reservation email should be sent to bo@example.com
    And a reservation awaiting confirmation email should be sent to keith@example.com

  @javascript
  Scenario: reservation confirmations not required
    Given Bo Jeanes does not require confirmation for his listing
    When Keith Contractor books a space for that listing
    Then a reservation confirmed email should be sent to keith@example.com
    Then a new reservation email should be sent to bo@example.com

  @javascript @borked
  Scenario: reservation gets confirmed
    Given Bo Jeanes has an unconfirmed reservation for Keith Contractor
    When the owner confirms the reservation
    Then a reservation confirmed email should be sent to keith@example.com

  @javascript @borked
  Scenario: confirmed then cancelled by visitor
    Given Bo Jeanes has a confirmed reservation for Keith Contractor
    When the visitor cancels the reservation
    Then a reservation cancelled email should be sent to bo@example.com

  @javascript @borked
  Scenario: confirmed then cancelled by owner
    Given Bo Jeanes has a confirmed reservation for Keith Contractor
    When the owner cancels the reservation
    Then a reservation cancelled by owner email should be sent to keith@example.com

  @javascript @borked
  Scenario: unconfirmed reservation gets cancelled by visitor
    Given Bo Jeanes has an unconfirmed reservation for Keith Contractor
    When the visitor cancels the reservation
    Then a reservation cancelled email should be sent to bo@example.com

  @javascript @borked
  Scenario: unconfirmed reservation gets rejected
    Given Bo Jeanes has an unconfirmed reservation for Keith Contractor
    When the owner rejects the reservation
    Then a reservation rejected email should be sent to keith@example.com
