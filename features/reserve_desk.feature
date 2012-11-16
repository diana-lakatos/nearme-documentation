Feature: A user can book a desk
  In order to hang out with cool dudes and work
  As a user
  I want to book a desk

  Background:
    Given a listing exists with quantity: 10
      And a user exists

  @javascript
  Scenario: A logged in user can book a desk
    Given I am logged in as the user
     When I go to the listing's page
      And I follow the reservation link for "16th November 2012"
     Then I should see "16 November"
      And I press "Request Booking Now"
      And a reservation period should exist with date: "2012-11-16"

  Scenario: A user cannot book a desk in the past
    Given I am logged in as the user
     When I try to book at the listing on "12th October 2010"
     Then I should be on the listing's page
      And I should see "Who do you think you are, Marty McFly? You can't book a desk in the past!"

  Scenario: A user cannot see the link to book a desk at a venue which is full
    Given the listing has the following reservations:
      | Date       | Number of Reservations |
      | 2010-10-15 | 10                 |
     When I go to the listing's page
     Then I should not see the reservation link for "15th October 2010"

  Scenario: A user cannot book a desk at a venue which is full
    Given the listing has the following reservations:
        | Date       | Number of Reservations |
        | 2010-10-15 | 10                 |
     When I try to book at the listing on "15th October 2010"
     Then I should be on the listing's page
      And I should see "There are no more desks left for that date. Sorry."

  Scenario: A user can only book one desk per day
    Given I am logged in as the user
    Given a reservation exists with listing: the listing, user: the user, date: "2010-10-15"
     When I go to the listing's page
      And I follow the reservation link for "15th October 2010"
     Then I should see "Awww Nuuu!"
      And I should see "You have already booked a desk for that date!"

  Scenario: A reservation is automatically confirmed if the listing doesnt require confirmation reservation
    Given a listing: "Rad Annex" exists with confirm_reservations: false
      And I am logged in as the user
     When I go to the listing: "Rad Annex"'s page
      And I follow the reservation link for "15th October 2010"
     Then I should see "You are making a reservation for: October 15, 2010"
      And I press "Reserve"
     Then I should be on the listing's page
      And a reservation period should exist with date: "2010-10-15"
      And I should see "booked a desk for the 15 October, 2010"

  Scenario: A reservation is not automatically confirmed if the listing requires confirmation reservation
    Given a listing: "Rad Annex" exists with confirm_reservations: true
      And I am logged in as the user
     When I go to the listing: "Rad Annex"'s page
      And I follow the reservation link for "15th October 2010"
     Then I should see "You are making a reservation for: October 15, 2010"
      And I press "Reserve"
     Then I should be on the listing's page
      And a reservation period should exist with date: "2010-10-15"
      And I should not see "booked a desk for the 15 October, 2010"

  Scenario: An anonymous user can log in to book a desk
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

  Scenario: Availability for the week is shown is shown
    Given the date is "11th October 2010"
    Given the listing has the following reservations:
      | Date       | Number of Reservations |
      | 2010-10-11 | 4                  |
      | 2010-10-12 | 10                 |
      | 2010-10-13 | 0                  |
      | 2010-10-14 | 3                  |
      | 2010-10-15 | 7                  |
    When I go to the listing's page
    Then I should see the following availability:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
      | 6          | 0          | 10         | 7          | 3          |

  Scenario: Show 3 weeks of dates on the show page, but 1 week on index pages
    When I go to the listing's page
    Then I should see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |
    When I go to the listings page
    Then I should see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
    But I should not see availability for dates:
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |

  # http://www.pivotaltracker.com/story/show/5724379
  Scenario: If viewing on a weekend, show the next week's schedule not the current week's
    Given the date is "16th October 2010"
    When I go to the listing's page
    Then I should see availability for dates:
      | 2010-10-18 | 2010-10-19 | 2010-10-20 | 2010-10-21 | 2010-10-22 |
      | 2010-10-25 | 2010-10-26 | 2010-10-27 | 2010-10-28 | 2010-10-29 |
      | 2010-11-01 | 2010-11-02 | 2010-11-03 | 2010-11-04 | 2010-11-05 |
    But I should not see availability for dates:
      | 2010-10-11 | 2010-10-12 | 2010-10-13 | 2010-10-14 | 2010-10-15 |
