@javascript
Feature: Secure documents upload
  Background:
    Given a user: "Admin" exists with name: "Admin User", admin: true
    Given an instance exists
    Given a documents upload with requirement mandatory exists
    Given a user exists
      And a company exists with creator: the user
      And a location_type exists with name: "Co-working"
      And a transactable_type_listing exists with name: "Listing"
      And a listed location in San Francisco that does not require confirmation
      And the transactable_type_listing exists
      And the transactable_type_buy_sell exists
      And product exists with name: "Awesome product"

  Scenario: User can make reservation and attach mandatory document
    Given a documents upload is mandatory
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    And I should see error file can't be blank
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files
    Then I travel back

  Scenario: User can make reservation without documents when documents upload is optional
    Given a documents upload is optional
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    Then I should see page with booking requests without files
    Then I travel back

  Scenario: User can make reservation with documents when documents upload is optional
    Given a documents upload is optional
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files
    Then I travel back

  Scenario: User can make reservation without documents
    Given a documents upload is vendor decides
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    Then I can not see section Required Documents

  Scenario: User can make reservation of listing with required documents
    Given a upload_obligation exists for listing
    Given a upload_obligation exists as required
    Given a document_requirements exist for listing
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    And I should see error file can't be blank
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files
    Then I travel back

  Scenario: User can make reservation of listing with optional documents
    Given a upload_obligation exists for listing
    Given a document requirement exists as optional
    Given a document_requirements exist for listing
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I make booking request
    Then I should see page with booking requests without files
    Then I travel back

  Scenario: User can make reservation of listing with optional documents file attached
    Given a upload_obligation exists for listing
    Given a document requirement exists as optional
    Given a document_requirements exist for listing
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    And I choose file
    And I make booking request
    Then I should see page with booking requests with files
    Then I travel back

  Scenario: User can make reservation of listing with existing not required
    Given a upload_obligation exists for listing
    Given a document requirement exists as not required
    Given a document_requirements exist for listing
    And I travel to early morning
    And I am logged in as the user
    And I visit the listing page
    And I book product
    And I enter data in the credit card form
    Then I can not see section Required Documents
    Then I travel back
