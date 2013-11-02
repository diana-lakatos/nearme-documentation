@javascript
Feature: A user can ask a question regarding a listing.
Listings administrator or creator can answer this question in a thread-like messaging system.
Message is marked read when its viewed by its recipient and can be removed from inbox by archiving.
Archivation is done separatedly for owner and listing admin/creator.

  Background:
    Given a user exists
    And a listing exists

  Scenario: A guest asks a question and gets a response from listings creator
    Given I am logged in as the user
    And I ask a question about a listing
    Then I should see this question in my inbox marked as read
    When I log in as this listings creator
    Then I should see this question in my inbox marked as unread
    And I should be able to read, answer and archive this question
