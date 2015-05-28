@javascript
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Background:
    And I am on the home page

  Scenario: Elasticsearch type of search should output expected results
    Given Elasticsearch is turned ON
    Then Elasticsearch transactables index should be created
    Given a listing in Auckland exists
    And a listing in Adelaide exists
    When I search for "Adelaide"
    And I make another search for "Auckland"
    And I leave the page and hit back
    Then I see a search result for the Auckland listing
    And I do not see a search result for the Adelaide listing
    Given Elasticsearch is turned OFF
    Then Elasticsearch transactables index should be dropped

  Scenario: Switching search engine type should not affect the search results
    Given Elasticsearch is turned ON
    Then Elasticsearch transactables index should be created
    Given a listing in Auckland exists
    And a listing in Adelaide exists
    When I search for "Adelaide"
    And I make another search for "Auckland"
    And I leave the page and hit back
    Then I see a search result for the Auckland listing
    And I do not see a search result for the Adelaide listing
    Given Elasticsearch is turned OFF
    Given a listing in Auckland exists
    And a listing in Adelaide exists
    And I am on the home page
    When I search for "Auckland"
    And I make another search for "Auckland"
    Then I see a search result for the Auckland listing
    And I do not see a search result for the Adelaide listing
    Then Elasticsearch transactables index should be dropped

  Scenario: Displaying no results found when searching for nonexisting product.
    Given the user exists
    And I log in as a user
    And the product_type exists
    And current instance is buyable
    When I search for product "TV"
    Then I should see "No results found"

  Scenario: Displaying search results for a product.
    Given Elasticsearch is turned ON
    Then Elasticsearch products index should be created
    Given the user exists
    And I log in as a user
    And the product_type exists
    And current instance is buyable
    And product exists with name: "Awesome product"
    When I search for product "product"
    Then I see a search results for the product
    Given Elasticsearch is turned OFF
    Then Elasticsearch products index should be dropped

  Scenario: Wrong Price Range
    Given Elasticsearch is turned ON
    Then Elasticsearch transactables index should be created
    Given a listing in Auckland exists
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 0 5
    And I do not see a search result for the Auckland listing
    Given Elasticsearch is turned OFF
    Then Elasticsearch transactables index should be dropped

  Scenario: Correct Price Range
    Given Elasticsearch is turned ON
    Then Elasticsearch transactables index should be created
    Given a listing in Auckland exists
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 0 15
    Given Elasticsearch is turned OFF
    Then Elasticsearch transactables index should be dropped
