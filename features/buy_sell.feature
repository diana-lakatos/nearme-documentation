@javascript
Feature: Buy Sell Marketplace
  In order to buy something on marketplace
  As a user
  I want to accomplish full checkout flow

  Scenario: A user can't purchase without filling in the extra checkout field
    Given Current marketplace is buy_sell
    And A buy sell product exist in current marketplace
    And a user exists
    And Extra fields are prepared
    And I am logged in as the user
    
    When I search for buy sell "Product"
    Then I should see relevant buy sell products

    When I add buy sell product to cart
    Then The product should be included in my cart

    When I begin Checkout process
    And  I fill in shippment details
    And  I choose shipping method
    Then I should see order summary page

    When I fill billing data
   Then  I shouldn't see order placed confirmation
   
   When  I fill in the extra checkout field
    And  I fill billing data
   Then  I should see order placed confirmation
