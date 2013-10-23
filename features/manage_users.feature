@javascript
Feature: As a user of the site
  In order to promote my company
  As a user
  I want to manage my company users

  Background:
    Given a user exists
      And I am logged in as the user
      And an instance exists
      And a company exists with creator: the user

  Scenario: A user can add new company user
    Given I am on the manage users page
    And a user exists with email: "existing_user@example.com", name: "existing_user"
    When I follow "Add user"
    And I fill in "user_email" with "existing_user@example.com"
    And I submit the form
    Then I should see info about succesfully added user

  Scenario: A user can remove other user from company
    Given I am on the manage users page
    And a user exists with email: "existing_user@example.com", name: "existing_user"
    When I follow "Add user"
    And I fill in "user_email" with "existing_user@example.com"
    And I submit the form 
    And I click remove user "existing_user"
    Then I should not see "existing_user@example.com" 

  Scenario: A user cannot add already added company user
    Given I am on the manage users page
    When I follow "Add user"
    And I fill in user email
    And I submit the form
    Then I should see "This user couldn't be invited as they are already associated with a company."
