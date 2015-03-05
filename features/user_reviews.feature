@javascript
Feature: Reviews for user are shown on user page
  Scenario: Blank state is shown if there are no reviews for user
    Given User exists
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees no reviews blank state

  Scenario: Reviews about seller are shown
    Given Reviews about the seller exist
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees two seller reviews

  Scenario: Reviews left by this seller/buyer shown
    Given User exists
    Given Reviews left by the user exist
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees sorting reviews dropdown with selected Left by this seller option
    And Review for buyer
    When Visitor clicks on Left by this buyer option
    Then List of reviews should be updated

  Scenario: Reviews left by this seller/buyer shown with pagination
    Given User exists
    Given Reviews left by the user exist for pagination
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees sorting reviews dropdown with selected Left by this seller option
    And Pagination with active first page
    When Visitor clicks on next page
    Then Sees second page
