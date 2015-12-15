@javascript
Feature: A user can communicate with other user with context

  Background:
    Given a user exists
    And a transactable exists

  Scenario: A guest asks a question and gets a response from listings creator
    Given I am logged in as the user
    And UserMessage alerts exist
    And I ask a question about a transactable
    Then I should see this question in my inbox marked as read
    And this listings creator should get email with notification
    When I log in as this listings creator
    Then I should see this question in my inbox marked as unread
    And I should be able to read, answer and archive this question
    And question owner should get email with notification

  Scenario: A user can send a message to another user from his profile page
    Given I am logged in as the user
    And I send a message to another user on his profile page
    Then I should see this message in my inbox marked as read
    When I log in as this user
    Then I should see this message in my inbox marked as unread
    And I should be able to read, answer and archive this question

  Scenario: A host can send a message to reservation owner
    Given a future_unconfirmed_reservation exists
    Given I am logged in as the reservation administrator
    When I am on the manage guests dashboard page
    And I send a message to reservation owner
    Then I should see this reservation message in my inbox marked as read
    When I am logged in as the reservation owner
    Then I should see this reservation message in my inbox marked as unread
    And I should be able to read, answer and archive this question
