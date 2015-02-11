@javascript
Feature: As a user of the site
  In order to promote my company
  As a user
  I want to manage my products

  Background:
    Given a user exists
      And I am logged in as the user
      And Current marketplace is buy_sell
      And a company exists with creator: the user
      And A shipping profile exists

  Scenario: A user can add new product
    Given I am adding new product
      And I fill products form with valid details
      And I submit the product form
      And I should see "Product has been created."
     Then Product with my details should be created
