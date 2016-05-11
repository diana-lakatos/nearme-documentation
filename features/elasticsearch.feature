@javascript @elasticsearch
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Scenario: Elasticsearch type of search should output expected results
    Given a indexed listing in Auckland exists
    And a listing in Adelaide exists
    And I am on the home page
    When I search for "Adelaide"
    When I make another search for "Auckland"
    Then I see a search result for the Auckland listing
    When I leave the page and hit back
    Then I see a search result for the Auckland listing
    And I do not see a search result for the Adelaide listing

  Scenario: Displaying search results for a product.
    Given the user exists
    And I log in as a user
    And the transactable_purchase exists with name: "Awesome product"
    Given search type is set to fulltext
    And I am on the home page
    And I refresh index
    When I search for product "product"
    Then I see a search results for the transactable_purchase

  Scenario: Wrong Price Range
    Given a listing in Auckland_fixed exists
    Given price slider are turned on
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 12 50
    Then I do not see a search result for the Auckland_fixed listing

  Scenario: Correct Price Range
    Given a listing in Auckland_fixed exists
    Given price slider are turned on
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 0 15
    Then I see a search result for the Auckland_fixed listing

  Scenario: It should be filterable
    Given no listings exists
    Given a listing in Auckland exists
    And I am on the home page
    When I go to the search page
    Then I should see filtering options
