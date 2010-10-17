Feature: Emails should be sent out informing parties about bookings
  In order to know or change the status of a booking
  As a user or workplace owner
  I want to receive emails updating me about the status of my bookings

  # Emails
  #
  # 1. When user creates a booking, one of (depending on confirmation setting) [DONE]:
  #   a) email to owner asking to confirm/decline [DONE]
  #   b) email to owner telling them that a booking has been made [DONE]
  # 2. When user cancels a booking, send email to owner
  # 3. When owner cancels a booking, send email to user
  # 4. When owner declines a booking, send email to user
  # 5. When owner confirms a booking, send email to user
  # 6. When user creates a booking, one of (depending on confirmation) [DONE]
  #   a) email to user telling them to wait for confirmation [DONE]
  #   b) email to user telling them their booking is confirmed [DONE]


  Background:
    Given the date is "13th October 2010"
    And a user: "Keith Contractor" exists
    And a user: "Bo Jeanes" exists

  Scenario: booking confirmations required
    Given a workplace: "Mocra" exists with creator: user "Bo Jeanes", confirm_bookings: true
    And I am logged in as user "Keith Contractor"
    When I go to the workplace's page
    And I follow the booking link for "15th October 2010"
    And I press "Book"
    Then 2 emails should be delivered
    And the 1st email should be delivered to user "Bo Jeanes"
    And the 1st email should have subject: "[DesksNear.Me] A new booking requires your confirmation"
    And the 2nd email should be delivered to user "Keith Contractor"
    And the 2nd email should have subject: "[DesksNear.Me] Your booking is pending confirmation"

  Scenario: booking confirmations not required
    Given a workplace: "Mocra" exists with creator: user "Bo Jeanes", confirm_bookings: false
    And I am logged in as user "Keith Contractor"
    When I go to the workplace's page
    And I follow the booking link for "15th October 2010"
    And I press "Book"
    Then 2 emails should be delivered
    And the 1st email should be delivered to user "Keith Contractor"
    And the 1st email should have subject: "[DesksNear.Me] Your booking has been confirmed"
    And the 2nd email should be delivered to user "Bo Jeanes"
    And the 2nd email should have subject: "[DesksNear.Me] You have a new booking"
