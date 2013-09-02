@javascript @emails
Feature: A user can add a space
  In order to let people easily list a space
  As a user
  I want to be able to step through an 'Add Space' wizard
  Background:
    Given a location_type exists with name: "Business"
    And a listing_type exists with name: "Desk"
    And a industry exists with name: "Industry"

  Scenario: An unregistered user starts by signing up
    Given a instance exists
    And I go to the home page
     And I follow "List Your" bookable noun
     And I sign up as a user in the modal
     Then I should see "List Your First" bookable noun
     When I fill in valid space details
     And I press "List my" bookable noun
     Then I should see "Your space was listed!"

  Scenario: An unregistered user starts a draft, comes back to it, and saves it
    Given a instance exists
    And I go to the home page
     And I follow "List Your" bookable noun
     And I sign up as a user in the modal
     Then I should see "List Your First" bookable noun
     And I partially fill in space details
     And I press "List my" bookable noun
     Then I should see "Please complete all fields! Alternatively, you can Save a Draft for later."
     And I press "Save as draft"
     Then I should see "Your draft has been saved!"
     And I fill in valid space details
     And I press "List my" bookable noun
     Then I should see "Your space was listed!"  

  Scenario: A draft listing does not show up in search
    Given a instance exists
    And I go to the home page
     And I follow "List Your" bookable noun
     And I sign up as a user in the modal
     Then I should see "List Your First" bookable noun
     And I partially fill in space details
     And I press "Save as draft"
     Then I go to the home page
     When I search for "USA"
     Then I should see "No results found"
     And I follow "Complete Your Listing"
     And I fill in valid space details
     And I press "List my" bookable noun
     Then I should see "Your space was listed!"
     Then I go to the home page
     When I search for "USA"
     Then I should see "We have a group of several shared desks available."
     
