@javascript
Feature: Documents upload
Background:
  Given a user exists with email: "valid@example.com", password: "password", name: "I am user", admin: true
  Given an instance exists

Scenario: Admin user creates documents upload
  And I log in as user  
  And I go to the instance documents upload page
  When I create documents upload
  Then I should see updated documents upload

Scenario: Admin user edits documents upload
  Given an exist documents upload
  And I log in as user  
  And I go to the instance documents upload page
  When I update documents upload
  Then I should see updated documents upload
