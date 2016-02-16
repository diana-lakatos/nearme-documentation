@javascript
Feature: Secure documents upload
  Background:
    Given a user: "Admin" exists with name: "Admin User", admin: true
    Given an instance exists
    Given a documents upload with requirement mandatory exists
    Given a user exists
      And a company exists with creator: the user
      And a transactable_type_listing exists with name: "Listing"
      And a location exists with company: the company
      And the transactable exists with location: the location
      And product exists with name: "Awesome product"

  Scenario: User can make reservation and attach mandatory document
    Given a documents upload is mandatory
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    And I should see error file can't be blank
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files

  Scenario: User can make reservation without documents when documents upload is optional
    Given a documents upload is optional
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    Then I should see page with booking requests without files

  Scenario: User can make reservation with documents when documents upload is optional
    Given a documents upload is optional
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files

  Scenario: User can make reservation without documents
    Given a documents upload is vendor decides
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    Then I can not see section Required Documents

  Scenario: User can make reservation of listing with required documents
    Given a upload_obligation exists for listing
    Given a upload_obligation exists as required
    Given a document_requirements exist for listing
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    And I should see error file can't be blank
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files

  Scenario: User can make reservation of listing with optional documents
    Given a upload_obligation exists for listing
    Given a document requirement exists as optional
    Given a document_requirements exist for listing
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    Then I should see page with booking requests without files

  Scenario: User can make reservation of listing with optional documents file attached
    Given a upload_obligation exists for listing
    Given a document requirement exists as optional
    Given a document_requirements exist for listing
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files

  Scenario: User can make reservation of listing with existing not required
    Given a upload_obligation exists for listing
    Given a document requirement exists as not required
    Given a document_requirements exist for listing
    And I am logged in as the user
    And I go to the transactable's page
    And I book product
    And I enter data in the credit card form
    Then I can not see section Required Documents

