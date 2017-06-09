Feature: User Cancels Reservation
  In order to not hang out with rad dudes
  As a user
  I want to cancel my reservation and be a filthy hobo who works on the street instead

  Background:
    Given a user exists
      And I am logged in as the user
      And the following transactables exist:
        | transactable          | name               |
        | Joe's Codin Garage | Joe's Codin Garage |
        | WoughThorks        | WoughThorks        |
      And the following unconfirmed_reservations exist:
       | transactable                      | date       | user     |
       | transactable "Joe's Codin Garage" | 2010-10-21 | the user |
       | transactable "WoughThorks"        | 2010-10-20 | the user |
       | transactable "WoughThorks"        | 2010-10-19 | the user |
       | transactable "Joe's Codin Garage" | 2010-10-18 | the user |

  Scenario: A user can see a list of their reservations
    When I travel to time "17th October 2010"
    When I go to the bookings page
    Then I should see the following reservations in order:
      |10/21/2010|
      |10/20/2010|
      |10/19/2010|
      |10/18/2010|

  Scenario: A user can cancel a reservation
    When I travel to time "17th October 2010"
    And I am on the bookings page
    When I cancel 2 reservation
    Then I should have a cancelled reservation on "20th October 2010"
    When I go to the bookings page
    Then I should see the following reservations in order:
      |10/21/2010|
      |10/19/2010|
      |10/18/2010|
