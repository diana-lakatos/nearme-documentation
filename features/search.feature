@javascript
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Background:
    And I am on the home page

  Scenario: Returning to the search results shows the previous results
    Given a listing in Auckland exists
      And a listing in Adelaide exists
     When I search for "Adelaide"
      And I make another search for "Auckland"
      And I leave the page and hit back
     Then I see a search result for the Auckland listing
      And I do not see a search result for the Adelaide listing

  Scenario: Subscribing on notification about new listings if no listings found for valid location.
    When I search for located "New Zealand"
    Then I should see "No results found"
    And I should see "Try another search query, or enter your email address below to be notified when a desk is added at this location."
    And I fill form with email field for subscribing on notification
    Then I should see a notification for my subscription
    And search notification created with "New Zealand"

  Scenario: Subscribing on notification about new listings if no listings found for valid location
            for registered user.
    Given the user exists
    And I log in as a user
    When I search for located "New Zealand"
    Then I should see "No results found"
    And I fill form for subscribing on notification
    Then I should see a notification for my subscription
    And search notification created with "New Zealand" for user
