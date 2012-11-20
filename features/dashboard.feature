Feature: As a user of the site
  In order for them to manage their reservations / listings
  As a user
  I want to view the dashboard

  Background:
    Given a user exists
      And I am logged in as the user
      And a location exists with creator: the user
      And a listing exists with location: the location, creator: the user, name: "Rad Annex", confirm_reservations: true

  Scenario: A user can visit the listing from the page
     When I go to the dashboard
      And I follow "Rad Annex"
     Then I should be on the location's page

  Scenario: A user can add a listing from this page
    Given I am on the dashboard
    When I follow "Create Listing"
      Then I should be on the new listing page

  Scenario: A user can see their listings
     When I am on the dashboard
     Then I should see "Rad Annex"
      And I should see "Edit Listing"
      And I should see "0 Unconfirmed"

  Scenario: A user can get to the edit listing page
     When I am on the dashboard
      And I follow "Edit Listing"
     Then I should see "Edit a listing"
      And I should be on the listing's edit page

