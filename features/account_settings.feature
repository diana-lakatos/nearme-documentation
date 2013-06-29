Feature: A user can edit their settings
  In order to escape an ex-girlfriend from emailing me
  As a user
  I want to be able to change my email address

  Background:
    Given a user exists
    And the date is "13th October 2010"
    And I am logged in as the user
    And a industry exists with name: "Computer Science"
    And a industry exists with name: "IT"
    And a industry exists with name: "Telecommunication"

  Scenario: A user can successfully edit their settings
    Given I go to the account settings page
    And I fill in "Your name" with "Keith"
    And I fill in "Job title" with "My job"
    And I fill in "Biography" with "This is my biography"
    And I fill in "Your email address" with "new@email.com"
    And I upload avatar
    When I press "Save Changes"
    Then I should see "You updated your account successfully."
    And a user should exist with email: "new@email.com"

  Scenario: A user can select industries for self
    Given a company exists with creator: the user
    And I go to the account settings page
    When I select industries for the user
    Then the user should be connected to selected industries

  Scenario: A user can select industries for company
    Given a company exists with creator: the user
    And I go to the account settings page
    When I select industries for a company
    Then a company should be connected to selected industries

  Scenario: A user with company will see company settings
    Given a company exists with creator: the user
    When I go to the account settings page
    Then I should see company settings

  Scenario: A user can update existing company
    Given a company exists with creator: the user
    And I go to the account settings page
    When I update company settings
    Then The company should be updated

  Scenario: A user without company will not see company settings
    When I go to the account settings page
    Then I should not see company settings

  Scenario: A user should not be allowed to provide invalid settings
    Given I go to the account settings page
    And I fill in "Your name" with ""
    And I fill in "Your email address" with ""
    When I press "Save Changes"
    Then I should see "can't be blank"
