Feature: User can communicate with support

  Background:
    Given a user: "Client" exists with name: "Client User"
    And a support admin
    And Alerts for support exist

  Scenario: Client can open support ticket and gets a response from instance admin
    Given I am logged in as the user
    And I open a support ticket
    Then I have one opened ticket
    And I receive request received email
    And support admin has one opened ticket
    And support admin receives support received email
    When I log in support admin
    Then I should see this support ticket
    And I should be able to answer and marked as resolved this support ticket
    And support ticked owner should get email with notification

  Scenario: Guest can open support ticket and gets a response from instance admin
    Given I open a guest support ticket
    Then I receive request received email
    And support admin has one opened ticket
    And support admin receives support received email
    When I log in support admin
    Then I should see this support ticket
    And I should be able to answer and marked as resolved this support ticket
    And support ticked owner should get email with notification
