Feature: A user can search for a workplace
  In order to make a booking on a workplace
  As a user
  I want to search for a workplace

  Scenario: A user searches for nothing
    Given Google is working correctly accepting mapping API calls
      And I go to the home page
     When I search for ""
     Then I should see "No results found"

  Scenario: A user searches for something silly
    Given Google is working correctly accepting mapping API calls
      And I go to the home page
     When I search for "this place wont exist"
     Then I should see "No results found"

  Scenario: A user searches for something which yields no results
    Given Google is working correctly accepting mapping API calls
      And I go to the home page
     When I search for "darwin"
     Then I should see "No results found"

  Scenario: A user searches using a location that that yields results
    Given Google is working correctly accepting mapping API calls
      And a workplace exists with name: "Rad Annex", latitude: -34.92577, longitude: 138.599732
      And a workplace exists with name: "Crap Annex", latitude: -34.92577, longitude: 198.599732
     When I go to the home page
      And I search for "adelaide"
      And I should see a Google Map
     Then I should see "Rad Annex"
      And I should not see "Crap Annex"

  Scenario: A user searches for "australia" and see only stuff in that country
    Given Google is working correctly accepting mapping API calls
      And a workplace exists with name: "Rad Annex", address: "Chicago, IL 60601, USA"
      And a workplace exists with name: "Crap Annex", address: "34 Olinda St Craigmore"
     When I go to the home page
      And I search for "united states"
      And I should see a Google Map
     Then I should see "Rad Annex"
      And I should not see "Crap Annex"
