@javascript
Feature: User can add locations to wish list

  Background:
    Given a company exists
    And a location exists with company: that company, name: "My loved location"
    And a transactable exists with location: that location, name: "My loved listing", quantity: 10, photos_count: 1, currency: "USD"
    And a user exists
    And wish lists are enabled for the instance
    And I am logged in as the user

  Scenario: User can add and remove transactable to wish list after logging in
    Given I go to the transactable's page
    When I click to Add to Favorites
    Then I should see "Remove from Favorites"
    When I click to Remove from Favorites
    Then I should see "Add to Favorites"

  Scenario: User can visit and manage wish list under dashboard section
    Given I am logged in as the user
    And I have one favorite item
    Then I visit dashboard wish list page
    Then I should see "My loved listing"
    When I click to Delete
    Then I should see "You don't have any items yet"

  Scenario: User can't visit wish list under dashboard section if the feature is disabled
    When wish lists are disabled for the instance
    When I visit dashboard wish list page
    Then I should see "Wish lists are disabled for this marketplace."

  Scenario: User can add product to wish list
  Given Current marketplace is buy_sell
    And A buy sell product exist in current marketplace
    And wish lists are enabled for the instance
    When I visit product page
    And I click to Add to Favorites
    Then I should see "Remove from Favorites"
