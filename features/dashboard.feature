Feature: As a user of the site
  In order for them to manage their bookings / workplaces
  As a user
  I want to view the dashboard

  Background:
    Given a user exists
      And I am logged in as the user

  Scenario: A user can visit the workplace from the page
    Given a workplace exists with creator: the user, name: "Rad Annex"
     When I go to the dashboard
      And I follow "Rad Annex"
     Then I should be on the workplace's page

  Scenario: A user can add a workplace from this page
    Given I am on the dashboard
    When I follow "Create Workplace"
      Then I should be on the new workplace page

  Scenario: A user can see their workplaces
    Given a workplace exists with creator: the user, name: "Rad Annex"
     When I am on the dashboard
     Then I should see "Rad Annex"
      And I should see "Edit Workplace"
      And I should see "0 Unconfirmed"

  Scenario: A user can get to the edit workplace page
    Given a workplace exists with creator: the user, name: "Rad Annex"
     When I am on the dashboard
      And I follow "Edit Workplace"
     Then I should see "Edit a workplace"
      And I should be on the workplace's edit page

