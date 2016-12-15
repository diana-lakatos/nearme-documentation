@javascript
Feature: Change Graph Queries
Background:
  Given a user exists with email: "valid@example.com", password: "password", name: "I am user", admin: true
  Given an instance exists
  And I log in as user

Scenario: Admin user adds graph query
  Given I am on admin graph queries
  When I create graph query
  Then I should see tag to insert graph query in liquid

Scenario: Admin user adds graph query
  Given I have users graph query defined
  And I am on admin graph queries
  When I remove users graph query
  Then I should see that query was removed
