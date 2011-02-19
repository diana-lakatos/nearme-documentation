Feature: A user can see a workplace
  In order to make a booking on a workplace
  As a user
  Can wee a workplace

  Scenario: A user can see a workplace
    Given a workplace exists with name: "Rad Annex", description: "Its a great place to work", url: "http://google.com"
     When I go to the workplace's page
     Then I should see "Rad Annex"
      And I should see "Its a great place to work"
      And I should see a Google Map
      And I should see "http://google.com"

  Scenario: A user can see whether or not the workplace booking requires confirmation (yes)
    Given a workplace exists with confirm_bookings: true
     When I go to the workplace's page
     Then I should see "Booking Confirmation Required: Yes"

  Scenario: A user can see whether or not the workplace booking requires confirmation (no)
    Given a workplace exists with confirm_bookings: false
     When I go to the workplace's page
     Then I should see "Booking Confirmation Required: No"

  Scenario: A can see who created the workplace
    Given a user exists with name: "Keith Pitt"
      And I am logged in as the user
      And a workplace exists with creator: the user
     When I go to the workplace's page
     Then I should see "Keith Pitt"
      And I should see the creators gravatar

  Scenario: View recent bookings in order of when they were made
    Given a workplace exists with confirm_bookings: false
    And the following bookings are made for the workplace:
      | User            | For        | At                    |
      | Keith Pitt      | 2011-10-10 | 2011-09-09 12:23:01pm |
      | Bodaniel Jeanes | 2012-01-01 | 2011-09-09 12:23:01pm |
      | Alex Eckermann  | 2011-08-08 | 2011-08-07 7:00:00am  |
      | Warren Seen     | 2011-10-10 | 2011-09-09 12:00:00pm |
    When I go to the workplace's page
    Then I should see the following booking events in the feed in order:
      | User            | For        | At                    |
      | Bodaniel Jeanes | 2012-01-01 | 2011-09-09 12:23:01pm |
      | Keith Pitt      | 2011-10-10 | 2011-09-09 12:23:01pm |
      | Warren Seen     | 2011-10-10 | 2011-09-09 12:00:00pm |
      | Alex Eckermann  | 2011-08-08 | 2011-08-07 7:00:00am  |

