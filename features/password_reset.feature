@javascript
Feature: A user can reset their password
  In order to login if they forget their password
  As a user
  I want to reset my password

  Background:
    Given a user exists

  Scenario: User requests password reset using modal
    And I performed search for "Auckland"
    When I begin to reset the password for that user
    Then I should be redirected to the previous search page
    And a password reset email should be sent to that user

  Scenario: User resets password from password reset link
    When I fill in the password reset form with a new password
    Then that users password should be changed
