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

  Scenario: A user can successfully edit his settings
    Given I go to the account settings page
    And I fill in "Full name" with "Keith"
    And I fill in "Job title" with "My job"
    And I fill in "Biography" with "This is my biography"
    And I fill in "Email" with "new@email.com"
    And I upload avatar
    When I press "Save"
    Then I should see "You updated your account successfully."
    And a user should exist with email: "new@email.com"

  Scenario: A user can select industries for self
    Given a company exists with creator: the user
    And I go to the account settings page
    When I select industries for the user
    Then the user should be connected to selected industries

  Scenario: A user should not be allowed to provide invalid settings
    Given I go to the account settings page
    And I fill in "Full name" with ""
    And I fill in "Email" with ""
    When I press "Save"
    Then I should see "can't be blank"

