Feature: A user can cancel a booking
  In order to not hang out with rad dudes
  As a user
  I want to cancel my booking and be a filthy hobo who works on the street instead

  Background:
    Given a user exists
      And I am logged in as the user
      And the following workplaces exist:
        | workplace          | name               |
        | Joe's Codin Garage | Joe's Codin Garage |
        | WoughThorks        | WoughThorks        |
      And the following bookings exist:
       | workplace                      | date       | user     |
       | workplace "Joe's Codin Garage" | 2010-10-18 | the user |
       | workplace "WoughThorks"        | 2010-10-19 | the user |
       | workplace "WoughThorks"        | 2010-10-20 | the user |
       | workplace "Joe's Codin Garage" | 2010-10-21 | the user |

  Scenario: A user can see a list of their bookings
    When I go to the dashboard page
    Then I should see the following bookings in order:
      | Joe's Codin Garage on October 18, 2010 (unconfirmed) |
      | WoughThorks on October 19, 2010 (unconfirmed)        |
      | WoughThorks on October 20, 2010 (unconfirmed)        |
      | Joe's Codin Garage on October 21, 2010 (unconfirmed) |

  Scenario: A user can cancel a booking
    Given I am on the dashboard page
    When I cancel the booking for "19th October 2010"
    Then I should see "You have cancelled the booking"
     And I should see the following bookings in order:
      | Joe's Codin Garage on October 18, 2010 (unconfirmed) |
      | WoughThorks on October 20, 2010 (unconfirmed)        |
      | Joe's Codin Garage on October 21, 2010 (unconfirmed) |
     And I should not see "WoughThorks on October 19, 2010"

  Scenario: A user can book a desk for a day on which they made a booking but it was cancelled
    Given I am on the dashboard page
     When I cancel the booking for "19th October 2010"
     When I go to workplace: "Joe's Codin Garage"'s page
      And I follow the booking link for "19th October 2010"
      And I press "Create Booking"
     Then I should be on workplace "Joe's Codin Garage"'s page
      And I should see "Booking Successful."

