Feature: Login to instance admin
Background:
  Given a user exists with email: "valid@example.com", password: "password", name: "I am user", admin: true
  Given an instance exists

Scenario: Admin user edits instance
  Given I go to the instance settings page
    And I should be on instance admin sign in page
    And I fill in invalid credentials and click LOG IN button
    And I fill in valid credentials and click LOG IN button
   Then I should be on the instance settings page
