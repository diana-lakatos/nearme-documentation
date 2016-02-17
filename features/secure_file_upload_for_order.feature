@javascript
Feature: User can add secure files to order
  Background:
    Given a user exists
    And I am logged in as the user
    And Current marketplace is buy_sell
    And Translation for default label exists
    And a documents upload with requirement mandatory exists
    And User has order on payment step

  Scenario: User sees error if mandatory but no file uploaded
    When User visits order payment page
    Then Sees default file label and field for upload
    When User clicks on Complete Checkout button
    Then Sees file cannot be blank

  Scenario: User doesn't see error if mandatory and file uploaded
    When User visits order payment page
    Then Sees default file label and field for upload
    And Attach file
    When I fill billing data
    Then Sees no error message for file
    And I should see order placed confirmation
    And File should be saved

  Scenario: User doesn't see error if optional
    Given a documents upload is optional
    When User visits order payment page
    Then Sees default file label and field for upload
    When I fill billing data
    And I should see order placed confirmation
    And File should not be saved

  Scenario: File is saved correctly if optional
    Given a documents upload is optional
    When User visits order payment page
    Then Sees default file label and field for upload
    And Attach file
    When I fill billing data
    And File should be saved

  Scenario: User doesn't see required documents if product documents not required
    Given Order has product with not required documents
    When User visits order payment page
    Then Should not see default file label and field for upload
    When I fill billing data
    Then I should see order placed confirmation
    And File should not be saved

  Scenario: Order has two products with different document requirements and upload all files
    Given Order has two products with required and optional documents
    When User visits order payment page
    Then User should see two labels and file fields
    And Attach file
    And Attach second file
    When I fill billing data
    Then I should see order placed confirmation
    And Two files should be saved

  Scenario: Order has two products with different document requirements and upload only required file
    Given Order has two products with required and optional documents
    When User visits order payment page
    Then User should see two labels and file fields
    And Attach file
    When I fill billing data
    Then Sees no error message for file
    And I should see order placed confirmation
    And File should be saved

  Scenario: Order has two products with different document requirements and no files uploaded
    Given Order has two products with required and optional documents
    When User visits order payment page
    Then User should see two labels and file fields
    When I fill billing data
    Then Sees file cannot be blank

  Scenario: User can buy product if document upload disabled
    Given Document upload is disabled
    Given Upload obligation for product is blank
    Given Document requirements for product is blank
    When User visits order payment page
    When I fill billing data
    Then I should see order placed confirmation
