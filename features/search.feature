Feature: A user can search for a workplace
  In order to make a booking on a workplace
  As a user
  I want to search for a workplace

  Scenario: A user searches for nothing
    Given I go to the home page
     When I search for ""
     Then I should see "Please enter a city or address"

  Scenario: A user searches for something silly
    Given I go to the home page
     When I search for "this place wont exist"
     Then I should see "No results found"

  Scenario: A user searches for something which yields no results
    Given I go to the home page
     When I search for "darwin"
     Then I should see "No results found"

  Scenario: A user searches using a location that that yields results
    Given a workplace exists with name: "Rad Annex", address: "Adelaide, South Australia"
      And a workplace exists with name: "Crap Annex", address: "Melbourne, Victoria"
      And the Sphinx indexes are updated
     When I go to the home page
      And I search for "adelaide"
      And I should see a Google Map
     Then I should see "Rad Annex"
      And I should not see "Crap Annex"
