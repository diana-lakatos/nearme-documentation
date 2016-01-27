@javascript
Feature: Buy Sell Marketplace
  In order to buy something on marketplace
  As a user
  I want to accomplish full checkout flow

  Background:
    Given a user exists
    And Current marketplace is buy_sell
    And I am logged in as the user
    Given A buy sell product exist in current marketplace
    When I search for buy sell "Product"
    Then I should see relevant buy sell products
    When I add buy sell product to cart
    Then The product should be included in my cart
    When I begin Checkout process
    When I fill in shippment details

  Scenario: A user can buy a product
    And  I choose shipping method
    Then I should see order summary page
    When I fill billing data
    Then I should see order summary page
    And  I should see order placed confirmation

  Scenario: A user can't purchase without filling in the extra checkout field
    Given Extra fields are prepared
    And  I choose shipping method
    Then I should see order summary page
    When I fill billing data
    And  I shouldn't see order placed confirmation
    Then I fill in the extra checkout field
    When I fill billing data
    And  I should see order placed confirmation

