Feature: Emails should be sent out informing parties about reservations
  In order to know or change the status of a reservation
  As a user or listing owner
  I want to receive emails updating me about the status of my reservations

  # Emails
  #
  # 1. When user creates a reservation, one of (depending on confirmation setting) [DONE]:
  #   a) email to owner asking to confirm/decline [DONE]
  #   b) email to owner telling them that a reservation has been made [DONE]
  # 2. When user cancels a reservation, send email to owner
  # 3. When owner cancels a reservation, send email to user
  # 4. When owner declines a reservation, send email to user
  # 5. When owner confirms a reservation, send email to user
  # 6. When user creates a reservation, one of (depending on confirmation) [DONE]
  #   a) email to user telling them to wait for confirmation [DONE]
  #   b) email to user telling them their reservation is confirmed [DONE]


  Background:
    Given the date is "13th October 2010"
    And a user: "Keith Contractor" exists with name: "Keith Contractor"
    And a user: "Bo Jeanes" exists with name: "Bo Jeanes"

  @javascript
  Scenario: reservation confirmations required (no comment)
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And I am logged in as user "Keith Contractor"
    When I go to the listing's page
    And I book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    Then 2 emails should be delivered
    And the 1st email should be delivered to user "Bo Jeanes"
    And the 1st email should have subject: "[DesksNear.Me] A new reservation requires your confirmation"
    And the 1st email should contain "Bo Jeanes,"
    And the 1st email should contain "Keith Contractor has made a reservation for Mocra"
    And the 2nd email should be delivered to user "Keith Contractor"
    And the 2nd email should have subject: "[DesksNear.Me] Your reservation is pending confirmation"
    And the 2nd email should contain "Dear Keith Contractor,"
    And the 2nd email should contain "You have made a reservation for Mocra"

  @javascript
  Scenario: reservation confirmations not required
    Given a listing: "Mocra" exists with creator: user "Bo Jeanes", confirm_reservations: false
    And I am logged in as user "Keith Contractor"
    When I go to the listing's page
    And I book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    Then 2 emails should be delivered
    And the 1st email should be delivered to user "Keith Contractor"
    And the 1st email should have subject: "[DesksNear.Me] Your reservation has been confirmed"
    And the 2nd email should be delivered to user "Bo Jeanes"
    And the 2nd email should have subject: "[DesksNear.Me] You have a new reservation"

  Scenario: reservation gets confirmed
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15"
    And all emails have been delivered
    And I am logged in as user "Bo Jeanes"
    When I follow "Dashboard"
    And I press "Confirm"
    Then 1 email should be delivered
    And the email should be delivered to user "Keith Contractor"
    And the email should have subject: "[DesksNear.Me] Your reservation has been confirmed"

  Scenario: confirmed then cancelled by user
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "confirmed"
    And all emails have been delivered
    And I am logged in as user "Keith Contractor"
    When I follow "Dashboard"
    And I press "Cancel"
    Then 1 email should be delivered
    And the email should be delivered to user "Bo Jeanes"
    And the email should have subject: "[DesksNear.Me] A reservation has been cancelled"

  Scenario: confirmed then cancelled by owner
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "confirmed"
    And all emails have been delivered
    And I am logged in as user "Bo Jeanes"
    When I follow "Dashboard"
    And I press "Cancel"
    Then 1 email should be delivered
    And the email should be delivered to user "Keith Contractor"
    And the email should have subject: "[DesksNear.Me] Your reservation at Mocra has been cancelled by the owner"

  Scenario: unconfirmed reservation gets cancelled by user
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "unconfirmed"
    And all emails have been delivered
    And I am logged in as user "Keith Contractor"
    When I follow "Dashboard"
    And I press "Cancel"
    Then 1 email should be delivered
    And the email should be delivered to user "Bo Jeanes"
    And the email should have subject: "[DesksNear.Me] A reservation has been cancelled"

  Scenario: unconfirmed reservation gets rejected
    Given a listing: "Mocra" exists with name: "Mocra", creator: user "Bo Jeanes", confirm_reservations: true
    And a reservation exists with listing: listing "Mocra", user: user "Keith Contractor", date: "2010-10-15", state: "unconfirmed"
    And all emails have been delivered
    And I am logged in as user "Bo Jeanes"
    When I follow "Dashboard"
    And I press "Reject"
    Then 1 email should be delivered
    And the email should be delivered to user "Keith Contractor"
    And the email should have subject: "[DesksNear.Me] Sorry, your reservation at Mocra has been rejected"
