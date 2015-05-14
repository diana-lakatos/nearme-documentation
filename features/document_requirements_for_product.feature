@javascript
Feature: User can add document requirements during product form submission
  Background:
    Given a user exists
      And I am logged in as the user
      And Current marketplace is buy_sell
      And a company exists with creator: the user
      And a shipping profile exists
      And document upload enabled

  Scenario: A user can add new product with document requirement
    Given I am adding new product
      And I fill products form with valid details
      And Fill in document requirement fields for product
      And I submit the product form
      And I should see "Product has been created."
     Then Product with my details should be created

  Scenario: A user can edit document requirements for product
    Given Product and document requirement for it exist
    When I edit first product
    And Fill in document requirement fields for product
    And Show form for another document requirement
    And Fill in form for another document requirement for product
    And I submit the product form
    And I should see "Product has been updated."
    And Visit edit product page
    And Updated document requirement should be present in product form
    And Two document requirements should be present in form
