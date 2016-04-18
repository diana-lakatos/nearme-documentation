@javascript @elasticsearch
Feature: A user can save a search
  In order to be able to use saved searches
  As a user
  I want to save a search on the results page

  Background:
    Given a user exists
    And I log in as a user
    And a listing in Auckland exists

  Scenario: Saving the search results actually saves them
    Given I am on the home page
    And saved search enabled
    When I search for "Auckland"
    And I see a search result for the Auckland listing
    And I click save search button
    And I enter saved search title
    And I click on saved search dialog Save button
    Then saved search is saved

  Scenario: Saved search title is updated when user edits it
    Given there is existing saved search
    And I am on the dashboard saved searches page
    When I edit the search title
    Then saved search is updated

  Scenario: Saved search title is not updated when use set't title to existing one
    Given there is existing saved search
    And I am on the dashboard saved searches page
    When I edit the search title setting title to already existing one
    Then saved search is not updated

  Scenario: User deletes the saved search
    Given there is existing saved search
    And I am on the dashboard saved searches page
    When I delete saved search
    Then saved search is deleted
    And page redirects back to the saved searches page

  Scenario: User uses the saved search name
    Given there is existing saved search
    And I am on the dashboard saved searches page
    When I click on search title
    Then I see a search result for the Auckland listing
