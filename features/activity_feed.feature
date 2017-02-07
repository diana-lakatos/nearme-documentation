@javascript
Feature: A user can interact with activity feeds
  Background:
    Given a user exists
    And the instance is a community instance
    And a project with name: "Project 1"
    And a topic with name: "Topic 1"
    And I am logged in as the user

  Scenario: A user can follow another user
    When I visit another user page
    Then I can see and press "Follow" button
    Then I should be following it
    Then I can see and press "Unfollow" button
    And I shouldn't be following it anymore

  Scenario: A user can follow a project
    When I visit project page
    Then I can see and press "Follow" button
    Then I should be following it
    Then I can see and press "Unfollow" button
    And I shouldn't be following it anymore

  Scenario: A user can follow a topic
    When I visit topic page
    Then I can see and press "Follow" button
    Then I should be following it
    Then I can see and press "Unfollow" button
    And I shouldn't be following it anymore

  Scenario: A user can't report a follow event
    When I visit another user page
    Then I can see and press "Follow" button
    Then I should be following it
    And I shouldn't see report as spam button

  Scenario: A user can update his status
    When I visit my page
    Then I can fill status update and submit it
    And I can see the event on the Activity Feed

  Scenario: User created project event exists
    When I visit project page
    Then I can see user created project event

  Scenario: User updated user status event exists
    When I visit another user page with status updates
    Then I should see the user status update This is the status update XYZ

  Scenario: User updated project status event exists
    When I visit project page with status
    Then I should see the project status update This is the project status XYZZ

  Scenario: Created topic status event exists
    When I visit topic page
    Then I should see the topic created event

