@timecop
Feature: User Cancels Reservation
  In order to not hang out with rad dudes
  As a user
  I want to cancel my reservation and be a filthy hobo who works on the street instead

  Background:
    Given a user exists
      And I freeze time at "17th October 2010"
      And I am logged in as the user
      And the following listings exist:
        | listing          | name               |
        | Joe's Codin Garage | Joe's Codin Garage |
        | WoughThorks        | WoughThorks        |
      And the following reservations exist:
       | listing                      | date       | user     |
       | listing "Joe's Codin Garage" | 2010-10-18 | the user |
       | listing "WoughThorks"        | 2010-10-19 | the user |
       | listing "WoughThorks"        | 2010-10-20 | the user |
       | listing "Joe's Codin Garage" | 2010-10-21 | the user |

  Scenario: A user can see a list of their reservations
    When I go to the bookings page
    Then I should see the following reservations in order:
      |Monday, October 18    |
      |Tuesday, October 19   |
      |Wednesday, October 20 |
      |Thursday, October 21 |

  Scenario: A user can cancel a reservation
    Given I am on the bookings page
    When I cancel 2 reservation
    Then I should have a cancelled reservation on "19th October 2010"
