Feature: An admin can edit shit
  In order to keep the site free of dicks
  As a user
  I want to be able to moderate

  Scenario: An admin can edit a workplace
    Given a user: "wally" exists
      And a workplace exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the workplace's edit page
      And I should see "Edit a workplace"
      And I should see "Creator"
  
  Scenario: An admin can successfully create a workplace with another creator
    Given a user: "Stevey" exists with name: "Stevey"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
      And I am on the new workplace page
     When I fill in "Name" with "Joe's Codin' Garage"
      And I fill in "Address" with "1 St John St Launceston TAS 7250"
      And I fill in "Maximum desks" with "2"
      And I fill in "Company URL" with "http://site.com"
      And I select "Stevey" from "Creator"
      And I choose "Yes"
      And I press "Create Workplace"
     Then 1 workplaces should exist with name: "Joe's Codin' Garage"
      And I should be on the workplace's page
      And I should see "Joe's Codin' Garage"
      And I should see "http://site.com"
      And I should see "Stevey"

  Scenario: An admin can edit another persons workplace
    Given a user: "wally" exists with name: "Wally"
      And a user: "steve" exists with name: "Stevey"
      And a workplace exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the workplace's page
      And I follow "Edit Workplace"
      And I should see "Edit a workplace"
      And I fill in "Name" with "Joe's Codin' Garage"
      And I fill in "Company URL" with "http://newurl.com"
      And I select "Stevey" from "Creator"
      And I press "Update Workplace"
     Then a workplace should exist with name: "Joe's Codin' Garage"
      And I should be on the workplace's page
      And I should see "http://newurl.com"
      And I should see "Stevey"

  Scenario: An admin can delete a workplace
    Given a user: "wally" exists with name: "Wally"
      And a workplace exists with creator: the user "wally"
      And an admin: "Adminardo" exists
      And I am logged in as the admin: "Adminardo"
     When I go to the workplace's page
      And I follow "Destroy (Admin Only)"
     Then I should be on the home page
      And I should see "Destroyed :("
      And a workplace should not exist with name: "Joe's Codin' Garage"

