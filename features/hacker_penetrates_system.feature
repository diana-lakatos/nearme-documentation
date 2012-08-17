Feature: Hacker Penetrates System
  In order to keep our customers data secure
  As a DNM Owner
  I want DNM to be impenatrable

  Scenario: A hacker cant edit a listing
    Given a user: "wally" exists
    And a listing exists with creator: the user "wally"
    And a user: "hacker" exists
    And I am logged in as the user: "hacker"
    When I go to the listing's edit page
    And I should not see "Edit a listing"
    And I should see "Could not find listing"

