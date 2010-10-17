Feature: A user can book a desk
  In order to hang out with cool dudes and work
  As a user
  I want to book a desk

  Background:
    Given a workplace exists with maximum_desks: 10
      And a user exists
      And the date is "16th October 2010"

  Scenario: A logged in user can book a desk
      And I am logged in as the user
     When I go to the workplace's page
      And I follow the booking link for "18th October 2010"
     Then I should see "You are making a booking for October 18, 2010"
      And I press "Book"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-18"

  @wip
  Scenario: An anonymous user can log in to book a desk
    When I go to the workplace's page
    And I follow the booking link for "18th October 2010"
    Then I should see "Do we know you?"
    When I log in as the user with Twitter
    # Then I should be logged in as the user
    And I should be on the workplace's new booking page
    And I should see "You are making a booking for October 18, 2010"
    And I press "Book"
    Then I should be on the workplace's page
    And a booking should exist with date: "2010-10-18"
       
  @wip
  Scenario: Availability for the week is shown is shown
    Given the workplace has the following bookings:
      | Date       | Number of Bookings |
      | 2010-10-18 | 4                  |
      | 2010-10-19 | 10                 |
      | 2010-10-20 | 0                  |
      | 2010-10-21 | 3                  |
      | 2010-10-22 | 7                  |
    When I go to the workplace's page
    Then I should see the following availability:
      | Date       | Available Desks |
      | 2010-10-18 | 6               |
      | 2010-10-19 | 0               |
      | 2010-10-20 | 10              |
      | 2010-10-21 | 7               |
      | 2010-10-22 | 3               |
