@javascript
Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard
  Background:
    Given a location_type exists with name: "Business"
    Given a location_type exists with name: "Public Space"
    Given a transactable_type_listing_no_action exists with name: "Listing"
    And a country_nz exists
    Given I go to the home page
    And I follow "List Your" bookable noun
    And I sign up as a user in the modal

  Scenario: An unregistered user starts a draft, comes back to it, and saves it
    And I partially fill in space details
   When I press "Submit"
   Then I should see "Please complete all fields! Alternatively, you can Save for later."
    And I should see shortened error messages
   When I press "Draft"
   Then I should see "Your draft has been saved!"
   When I fill in valid space details
    And I press "Submit"
   Then I should see "Your Desk was listed!"

  Scenario: An unregistered user starts by signing up
    When I fill in valid space details
    And I press "Submit"
    Then I should see "Your Desk was listed!"

