@javascript @elasticsearch @elasticreindex
Feature: A user can search for a listing
  In order to make a reservation on a listing
  As a user
  I want to search for a listing

  Scenario: Elasticsearch type of search should output expected results
    Given a listing in Auckland exists
    And a listing in Adelaide exists
    And I am on the home page
    When I search for "Adelaide"
    And I make another search for "Auckland"
    And I leave the page and hit back
    Then I see a search result for the Auckland listing
    And I do not see a search result for the Adelaide listing

  Scenario: Switching search engine type should not affect the search results
    Given a listing in Auckland exists
    And a listing in Adelaide exists
    And I am on the home page
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

  Scenario: Displaying no results found when searching for nonexisting product.
    Given the user exists
    And the product_type exists
    And I log in as a user
    When I search for product "TV"
    Then I should see "No results found"

  Scenario: Displaying search results for a product.
    Given the user exists
    And the product_type exists
    And I log in as a user
    And product exists with name: "Awesome product"
    When I search for product "product"
    Then I see a search results for the product

  Scenario: Wrong Price Range
    Given a listing in Auckland exists
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 0 5
    And I do not see a search result for the Auckland listing

  Scenario: Correct Price Range
    Given a listing in Auckland exists
    Given Auckland listing has fixed_price: 10
    When I search for "Auckland" with prices 0 15

  Scenario: It should be filterable
    Given no listings exists
    Given a listing in Auckland exists
    Given a listing in Adelaide exists
    Given a listing in Wellington exists
    And I am on the home page
    When I search for ""
    Then I should see filtering options
