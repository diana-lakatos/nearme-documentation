Feature: Hacker Penetrates System
  In order to keep our customers data secure
  As a DNM Owner
  I want DNM to be impenatrable

  Scenario: A hacker cant edit a transactable
    Given a user: "wally" exists
    And a transactable exists with creator: the user "wally"
    And a user: "hacker" exists
    And I am logged in as the user: "hacker"
    When I view that transactable's edit page
    Then I should not see "Edit a listing"
