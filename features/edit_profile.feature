Feature: A user can edit their settings
  In order to escape an ex-girlfriend from emailing me
  As a user
  I want to be able to change my email address

  Background:
    Given a user exists
    And I am logged in as the user
    And a transactable_type_listing exists with name: "Listing"

  Scenario: A user can successfully edit his settings
    Given a user_custom_attribute exists with name: "job_title", attribute_type: "string", html_tag: "input", label: "Job title"
    Given a user_custom_attribute exists with name: "biography", attribute_type: "string", html_tag: "textarea", label: "Biography"
    Given a form configuration with custom attributes is set
    Given I go to the account settings page
    And I fill in "First name" with "Keith"
    And I fill in "Job title" with "My job"
    And I fill in "Biography" with "This is my biography"
    And I fill in "Email" with "new@email.com"
    And I upload avatar
    When I press "Save"
    Then I should see "You have updated your account successfully."
    And a user should exist with email: "new@email.com"

  Scenario: A user should not be allowed to provide invalid settings
    Given I go to the account settings page
    And I fill in "First name" with ""
    And I fill in "Email" with ""
    When I press "Save"
    Then I should see "can't be blank"

