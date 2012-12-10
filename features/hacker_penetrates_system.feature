Feature: Hacker Penetrates System
  In order to keep our customers data secure
  As a DNM Owner
  I want DNM to be impenatrable

  Scenario: A hacker cant edit a listing
    Given a user: "wally" exists
    And a listing exists with creator: the user "wally"
    And a user: "hacker" exists
    And I am logged in as the user: "hacker"
    When I view that listing's edit page
    Then I should not see "Edit a listing"
