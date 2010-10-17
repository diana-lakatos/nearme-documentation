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
