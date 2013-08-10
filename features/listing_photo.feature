@javascript @photo
Feature: User can manipulate photos for lisitng

  Background:
    Given a user exists
    And I am logged in as the user
    And a company exists with creator: the user
    And a location exists with company: the company, creator: the user, street: "Rad Annex House"
    And a listing exists with location: the location, creator: the user
    And I am on the manage listing page

  Scenario: User can crop image
    And I open rotate and crop modal
    Then I crop image
    And I should see cropped photo

  Scenario: User can rotate image
    And I open rotate and crop modal
    Then I rotate image
    And I should see rotated photo



