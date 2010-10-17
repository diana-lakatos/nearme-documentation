@wip
Feature: Emails should be sent out informing parties about bookings
  In order to know or change the status of a booking
  As a user or workplace owner
  I want to receive emails updating me about the status of my bookings

  Background:
    Given a user: "Keith Contractor" exists
    And a user: "Bo Jeanes" exists

  Scenario: booking confirmations required
    Given a workplace: "Mocra" with creator: "Bo Jeanes" exists and confirm bookings: true

  Scenario: booking confirmations not required
    Given a workplace: "Mocra" with creator: "Bo Jeanes" exists and confirm bookings: false
