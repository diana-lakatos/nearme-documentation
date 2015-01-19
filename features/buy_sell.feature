@javascript
Feature: Buy Sell Marketplace
  In order to buy something on marketplace
  As a user
  I want to accomplish full checkout flow

  Background:
    Given a user exists
    And I am logged in as the user
    And Current marketplace is buy_sell

  Scenario: A user can buy a product
    Given A buy sell product exist in current marketplace
    When I search for buy sell "Product"
    Then I should see relevant buy sell products
    When I add buy sell product to cart
    Then The product should be included in my cart
    When I begin Checkout process
    When I fill in shippment details
    And  I choose shipping method
    Then I should see order summary page
    When I fill billing data
    Then I should see order summary page
    And  I should see order placed confirmation


  Scenario: A user from not supported country should not be able to buy product
    Given A buy sell product exist in current marketplace
    Given Instance without payment gateway defined
    When I search for buy sell "Product"
    Then I should see relevant buy sell products
    When I add buy sell product to cart
    Then The product should not be included in my cart

