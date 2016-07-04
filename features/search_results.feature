@javascript @elasticsearch
Feature: A user can see search results
  In order to choose listing
  As a user
  I want to see search results

  Background:
    Given a listing in Auckland exists
    And I am on the home page

  Scenario: Shows $0 only for day if all prices are 0
    Given Auckland listing has prices: 0, 0, 0
     When I search for "Auckland"
     Then I should not see "$0 / day"
     Then I should not see "$0 / 7 days"
     Then I should not see "$0 / 30 days"

  Scenario: Shows $10 only for week, if other prices are 0 or nil
    Given Auckland listing has prices: 0, 10, nil
     When I search for "Auckland"
     Then I should not see "$0 / day"
     Then I should see "$10 / 7 days"
     Then I should not see "$0 / 30 days"

  Scenario: Shows $10 only for month, if other prices are 0 or nil
    Given Auckland listing has prices: nil, 0, 10
     When I search for "Auckland"
     Then I should not see "$0 / day"
     Then I should not see "$0 / 7 days"
     Then I should see "$10 / 30 days"

  Scenario: Shows correct prices for all periods if they are greater than 0
    Given Auckland listing has prices: 10, 60, 200
     When I search for "Auckland"
     Then I should see "$10 / day"
     Then I should not see "$60 / 7 days"
     Then I should not see "$200 / 30 days"

  Scenario: Shows correct next/prev canonicals
    Given enough listings in Auckland exists to paginate
    When I search for "Auckland" with 2 per page
    Then I should ensure "next" canonical exists
    Then I click to go to next page
    Then I should ensure "prev" canonical exists
