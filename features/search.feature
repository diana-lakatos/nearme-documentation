Feature: A user can search for a workplace
  In order to make a booking on a workplace
  As a user
  Can search for a workplace

Scenario: A user searches for nothing
  Given I go to the home page
   When I search for ""
   Then I should see "Please enter a country, city or company"

Scenario: A user searches for something which yields no results
  Given I go to the home page
   When I search for "darwin"
   Then I should see "No results found"

Scenario: A user searches using a company name that that yields results
  Given a workplace exists with name: "Rad Annex", address: "Adelaide, South Australia"
    And a workplace exists with name: "Crap Caravan", address: "Melbourne, Victoria"
   When I go to the home page
    And I search for "annex"
   Then I should see "Rad Annex"
    And I should see /Workplaces matching: "annex"/
    And I should not see "Crap Caravan"

Scenario: A user searches using a location that that yields results
  Given a workplace exists with name: "Rad Annex", address: "Adelaide, South Australia"
    And a workplace exists with name: "Crap Annex", address: "Melbourne, Victoria"
   When I go to the home page
    And I search for "adelaide"
   Then I should see "Rad Annex"
    And I should see /Workplaces near: "Adelaide SA, Australia"/
    And I should not see "Crap Annex"
