@javascript
Feature: A user can see search results
  In order to choose listing
  As a user
  I want to see search results

  Background:
    Given I am on the home page
      Then I open my debugger
      And a listing in Auckland exists

  Scenario: Shows $0 only for day if all prices are 0
    Given Auckland listing has prices: 0, 0, 0
     When I search for "Auckland"
     Then I should not see "$0/day"
     Then I should not see "$0/wk"
     Then I should not see "$0/mo"

  Scenario: Shows $0 only for day, if other prices are 0 or nil
    Given Auckland listing has prices: nil, nil, 0
     When I search for "Auckland"
     Then I should not see "$0/day"
     Then I should not see "$0/wk"
     Then I should not see "$0/mo"

  Scenario: Shows $10 only for week, if other prices are 0 or nil
    Given Auckland listing has prices: 0, 10, nil
     When I search for "Auckland"
     Then I should not see "$0/day"
     Then I should see "$10/wk"
     Then I should not see "$0/mo"

  Scenario: Shows $10 only for month, if other prices are 0 or nil
    Given Auckland listing has prices: nil, 0, 10
     When I search for "Auckland"
     Then I should not see "$0/day"
     Then I should not see "$0/wk"
     Then I should see "$10/mo"

  Scenario: Shows correct prices for all periods if they are greater than 0
    Given Auckland listing has prices: 10, 60, 200
     When I search for "Auckland"
     Then I should see "$10/day"
     Then I should see "$60/wk"
     Then I should see "$200/mo"
