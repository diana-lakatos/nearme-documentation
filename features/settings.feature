Feature: A user can edit their settings
  In order to escape an ex-girlfriend from emailing me
  As a user
  I want to be able to change my email address

  Background:
    Given a user exists
    And I am logged in as the user
    And a industry exists with name: "Computer Science"
    And a industry exists with name: "IT"
    And a industry exists with name: "Telecommunication"

  Scenario: A user can select industries for company
    Given a company exists with creator: the user
    And I go to the settings page
    When I select industries for company
    Then company should be connected to selected industries

  @javascript
  Scenario: A user with listing will see settings
    Given a company exists with creator: the user
    Given a location exists with company: the company
    Given a listing exists with location: the location
    And I am on the home page
    When I follow "Manage Desks"
    Then I should see "Company"

  Scenario: A user can update existing company
    Given a company exists with creator: the user
    And I go to the settings page
    When I update company settings
    Then The company should be updated

  @javascript
  Scenario: A user can update white label settings
    Given a company exists with creator: the user
    And I go to the white label settings page
    When I enable white label settings
    When I update company white label settings
    Then I should see "Great, white-label details have been updated"
     And The company white label settings should be updated

  @javascript
  Scenario: A user without listing will not see settings
    Given a company exists with creator: the user
      And a location exists with company: the company
      And I am on the home page
    Then I should not see "Manage Desks"

  @javascript
  Scenario: A user with one inactive listing will not see settings
    Given a company exists with creator: the user
      And a location exists with company: the company
      And a listing exists with location: the location, draft: "#{Time.zone.now}"
      And I am on the home page
    Then I should not see "Manage Desks"
