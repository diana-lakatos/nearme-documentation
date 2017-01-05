Feature: A admin user can login as another user
  In order to let admin manage users data
  As an admin
  I want to login as another user

  Background:
    Given a user: "Admin" exists with name: "Admin User", admin: true
    And a user: "Client" exists with name: "Client User"

  Scenario: An admin user can login as another user
    Given I am logged in as user: "Admin"
    And I am in the admin panel
    When I choose to Login As user: "Client"
    Then I should be logged in as user: "Client"
    And I should see "browsing the website as Client User"
    When I follow "Go back"
    Then I should be logged in as user: "Admin"
    And I should be in the admin panel

