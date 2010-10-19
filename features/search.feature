Feature: A user can search for a workplace
  In order to make a booking on a workplace
  As a user
  I want to search for a workplace

  Scenario: A user searches for nothing
     Given I go to the home page
     When I search for ""
     Then I should see "No results found"

  Scenario: A user searches for something silly
    Given I go to the home page
     When I search for "bung"
     Then I should see "No results found"

  Scenario: A user searches for something which yields no results
    Given I go to the home page
     When I search for "darwin"
     Then I should see "No results found"

  Scenario: A user searches using a location that that yields results
    Given a workplace exists with name: "Rad Annex", address: "34 Olinda St Craigmore"
    Given a workplace exists with name: "Crap Annex", address: "Chicago, IL 60601, USA"
     When I go to the home page
      And I search for "adelaide"
      And I should see a Google Map
     Then I should see "Rad Annex"
      And I should not see "Crap Annex"

  Scenario: A user searches for "australia" and see only stuff in that country
    Given a workplace exists with name: "Rad Annex", address: "34 Olinda St Craigmore"
    Given a workplace exists with name: "Crap Annex", address: "Chicago, IL 60601, USA"
     When I go to the home page
      And I search for "australia"
     Then I should see a Google Map
      And I should see "Rad Annex"
      And I should not see "Crap Annex"
