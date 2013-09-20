Feature: There can be many instances of the application
Background:
  Given a admin exists
  Given an instance exists
  And I log in as admin

Scenario: Admin user creates new instance
  Given I am on the admin instances page
  And I follow "New Instance"
  When I fill instance form with valid details
  And I press "Create Instance"
  Then I should see created instance show page

Scenario: Admin user edits instance
  Given I am on the admin instances page
  Then I should see instances list
   And I edit instance
  When I fill instance form with valid details
  And I press "Update Instance"
  Then I should see updated instance show page
