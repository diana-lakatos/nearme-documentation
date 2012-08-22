Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

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

  Scenario: A user searches for "new zealand" and see only stuff in that country
    Given a listing in Auckland exists
    And a listing in Cleveland exists
    When I go to the home page
    And I search for "usa"
    Then I should see a Google Map
    And I see a search result for the Cleveland listing
    And I do not see a search result for the Auckland listing


  @future
  Scenario: a non member user searches for a private listing

  @future
  Scenario: a member user searches for a private listing
