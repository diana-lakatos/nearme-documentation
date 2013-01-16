Feature: A user can see a space
  In order to make a reservation on a listing
  As a user
  Can wee a space

  Scenario: A user can see a listing
    Given a listing exists with name: "Rad Annex", description: "Its a great place to work"
     When I go to the listing's page
     Then I should see "Rad Annex"
      And I should see "Its a great place to work"
      And I should see a Google Map
      And I should see a link to "http://google.com"

  @wip
  Scenario: A can see who created the listing
    Given a user exists with name: "Keith Pitt"
      And I am logged in as the user
      And a location exists with creator: the user
      And a listing exists with location: the location
     When I go to the listing's page
     And  I follow "Host"
     Then I should see "Keith Pitt"
      And I should see the creators gravatar


