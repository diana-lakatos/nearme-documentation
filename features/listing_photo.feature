@javascript @photo
Feature: User can manipulate photos for listing

  Background:
    Given a user exists
    And I am logged in as the user
    And a company exists with creator: the user
    And a location exists with company: the company, creator: the user, street: "Rad Annex House"
    And a listing exists with location: the location, creator: the user
    And I am on the manage listing page

  Scenario: User can crop image
    Given I open rotate and crop modal
     When I crop image
     Then I should see "Your changes will be applied"
      And I should see cropped photo

  Scenario: User can rotate image
    Given I open rotate and crop modal
     When I rotate image
     Then I should see "Your changes will be applied"
      And I should see rotated photo



