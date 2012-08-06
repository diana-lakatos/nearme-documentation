Feature: A user can see a listing
  In order to make a reservation on a listing
  As a user
  Can wee a listing

  Scenario: A user can see a listing
    Given a listing exists with name: "Rad Annex", description: "Its a great place to work"
     When I go to the listing's page
     Then I should see "Rad Annex"
      And I should see "Its a great place to work"
      And I should see a Google Map
      And I should see "http://google.com"

  Scenario: A user can see whether or not the listing reservation requires confirmation (yes)
    Given a listing exists with confirm_reservations: true
     When I go to the listing's page
     Then I should see "Reservation Confirmation Required: Yes"

  Scenario: A user can see whether or not the listing reservation requires confirmation (no)
    Given a listing exists with confirm_reservations: false
     When I go to the listing's page
     Then I should see "Reservation Confirmation Required: No"

  Scenario: A can see who created the listing
    Given a user exists with name: "Keith Pitt"
      And I am logged in as the user
      And a listing exists with creator: the user
     When I go to the listing's page
     Then I should see "Keith Pitt"
      And I should see the creators gravatar

  Scenario: View recent reservations in order of when they were made
    Given a listing exists with confirm_reservations: false
    And the following reservations are made for the listing:
      | User            | For        | At                    |
      | Keith Pitt      | 2011-10-10 | 2011-09-09 12:23:01pm |
      | Bodaniel Jeanes | 2012-01-01 | 2011-09-09 12:23:02pm |
      | Alex Eckermann  | 2011-08-08 | 2011-08-07 7:00:00am  |
      | Warren Seen     | 2011-10-10 | 2011-09-09 12:00:00pm |
    When I go to the listing's page
    Then I should see the following reservation events in the feed in order:
      | User            | For        | At                    |
      | Bodaniel Jeanes | 2012-01-01 | 2011-09-09 12:23:02pm |
      | Keith Pitt      | 2011-10-10 | 2011-09-09 12:23:01pm |
      | Warren Seen     | 2011-10-10 | 2011-09-09 12:00:00pm |
      | Alex Eckermann  | 2011-08-08 | 2011-08-07 7:00:00am  |

