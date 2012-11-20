Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a listing

  Background:
    Given a company exists
      And a location exists with company: that company
      And a listing exists with location: that location, quantity: 10
      And a user exists

  @javascript
  Scenario: A logged in user can book a listing
    Given I am logged in as the user
     When I go to the location's page
      And I book space for:
          | Listing     | Date   | Quantity  |
          | the listing | Monday  | 1        |
          | the listing | Tuesday | 1        |
     Then the user should have the listing reserved for 'Monday'
      And the user should have the listing reserved for 'Tuesday'

  @javascript
  @future
  Scenario: A user cannot book a desk in the past

  @javascript
  @wip
  Scenario: Booking for a 'automatically confirm' listing should show relevant details
    Given I am logged in as the user
    And bookings for the listing do not need to be confirmed
    When I go to the location's page
    And I select to book space for:
      | Listing | Date | Quantity|
      | the listing | Monday | 1 |
    And I click to review the booking
    Then I should see "This host manually confirms all bookings before payment"

  @javascript
  @wip
  Scenario: Booking for a non-'automatically confirm' listing should show relevant details
    Given I am logged in as the user
    And bookings for that listing do need to be confirmed
    When I go to the location's page
    And I select to book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |
    And I click to review the booking
    Then I should not see "This host manually confirms all bookings before payment"

  @javascript
  @future
  Scenario: A user cannot see the link to book a desk at a venue which is full
    Given the listing has the following reservations:
      | Date   | Quantity |
      | Monday | 10       |
    When I go to the locatoin's page
    Then I can't select to book space for:
      | Listing     | Date   | Quantity |
      | the listing | Monday | 1        |

  @javascript
  @future
  Scenario: An anonymous user should be able to sign up during the reservation
    Given the Twitter OAuth request is successful
     When I go to the listing's page
      And I follow the reservation link for "15th October 2010"
     Then I should see "Do we know you?"
     When I follow "Sign In/Up"
      And I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Your name" with "Jermaine"
      And I fill in "Your email address" with "myemail@example.com"
      And I press "Sign up and get started"
     Then I should be on the listing's new reservation page
      And I should see "You are making a reservation for: October 15, 2010"
      And I press "Reserve"
     Then I should be on the listing's page
      And a reservation period should exist with date: "2010-10-15"

