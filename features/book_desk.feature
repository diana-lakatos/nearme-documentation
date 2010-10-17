Feature: A user can book a desk
  In order to hang out with cool dudes and work
  As a user
  I want to book a desk

  Background:
    Given a workplace exists with maximum_desks: 10
      And a user exists
      And the date is "13th October 2010"
      
  Scenario: A logged in user can book a desk
    Given I am logged in as the user
     When I go to the workplace's page
      And I follow the booking link for "15th October 2010"
     Then I should see "You are making a booking for October 15, 2010"
      And I press "Book"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-15"

  Scenario: A booking is automatically confirmed if the workplace doesnt require confirmation booking
    Given a workplace: "Rad Annex" exists with confirm_bookings: false
      And I am logged in as the user
     When I go to the workplace: "Rad Annex"'s page
      And I follow the booking link for "15th October 2010"
     Then I should see "You are making a booking for October 15, 2010"
      And I press "Book"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-15"
      And I should see "booked a desk for the 15 October, 2010"

  Scenario: A booking is not automatically confirmed if the workplace requires confirmation booking
    Given a workplace: "Rad Annex" exists with confirm_bookings: true
      And I am logged in as the user
     When I go to the workplace: "Rad Annex"'s page
      And I follow the booking link for "15th October 2010"
     Then I should see "You are making a booking for October 15, 2010"
      And I press "Create Booking"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-15"
      And I should not see "booked a desk for the 15 October, 2010"

  Scenario: An anonymous user can log in to book a desk
    Given the Twitter OAuth request is successful
     When I go to the workplace's page
      And I follow the booking link for "15th October 2010"
     Then I should see "Do we know you?"
     When I follow "Sign In/Up"
      And I follow "Twitter"
      And I grant access to the Twitter application for Twitter user "jerkcity" with ID 999
      And I fill in "Email" with "myemail@example.com"
      And I press "Sign up"
     Then I should be on the workplace's new booking page
      And I should see "You are making a booking for October 15, 2010"
      And I press "Book"
     Then I should be on the workplace's page
      And a booking should exist with date: "2010-10-15"

  Scenario: Availability for the week is shown is shown
    Given the workplace has the following bookings:
      | Date       | Number of Bookings |
      | 2010-10-11 | 4                  |
      | 2010-10-12 | 10                 |
      | 2010-10-13 | 0                  |
      | 2010-10-14 | 3                  |
      | 2010-10-15 | 7                  |
    When I go to the workplace's page
    Then I should see the following availability:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
      | 6          | 0          | 10         | 7          | 3          |

  # http://www.pivotaltracker.com/story/show/5724372
  Scenario: Show 3 weeks of dates on the show page, but 1 week on index pages
    When I go to the workplace's page
    Then I should see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |
    When I follow "Workplaces"
    Then I should see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
    But I should not see availability for dates:
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |

  # http://www.pivotaltracker.com/story/show/5724379
  Scenario: If viewing on a weekend, show the next week's schedule not the current week's
    Given the date is "16th October 2010"
    When I go to the workplace's page
    Then I should see availability for dates:
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |
      | 2010-11-01 | 2010-11-02 | 2010-11-03 | 2010-11-04 | 2010-11-05 |
    But I should not see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
