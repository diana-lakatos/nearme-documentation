@javascript
Feature: A user can add a product
  In order to let people easily create new product
  As a user
  I want to be able to step through an 'Add Product' wizard
  Background:
    Given a product_type exists with name: "Sock"
    And current instance with integrated shipping
    And a state exists
    And a spree_country exists
    And a country_nz exists
    And I go to the home page
    And I follow "List Your" bookable noun
    And I sign up as a user in the modal
    Then I should see "List a New" bookable noun

  Scenario: An unregistered user starts a draft, comes back to it, and saves it
    And I partially fill in product details
    And I press "Continue and Preview Listing"
    Then I should see "Please complete all fields!"
    And I press "Save for Later"
    Then I should see "Your draft has been saved!"
    And I fill in valid product details
    And I press "Continue and Preview Listing"
    Then I should see "Your Sock was listed!"

  Scenario: An unregistered user starts by signing up
    And I fill in valid product details
    And I press "Continue and Preview Listing"
    Then I should see "Your Sock was listed!"

  Scenario: Create product with integrated shipping
    And I fill in valid product details with integrated shipping
    And I press "Continue and Preview Listing"
    Then I should see "Your Sock was listed!"

  Scenario: A draft product does not show up in search
    And I partially fill in product details
    And I press "Save for Later"
    Then I go to the home page
    And I search for product "Nice Sock"
    Then I should see "No results found"
    And I follow "Complete Your Sock"
    And I fill in valid product details
    And I press "Continue and Preview Listing"
    Then I should see "Your Sock was listed!"
    Then I go to the home page
    And I search for product "Nice Sock"
    Then I should see "1 results for"
