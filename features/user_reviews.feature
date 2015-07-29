@javascript
Feature: Reviews for user are shown on user page
  Scenario: Blank state is shown if there are no reviews for user
    Given User exists
    Given Rating systems exists
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees no reviews blank state

  Scenario: Reviews about seller are shown
    Given User exists
    Given Rating systems exists
    Given Reviews about the seller exist
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees two seller reviews

  Scenario: Reviews left by this seller/buyer shown
    Given User exists
    Given Rating systems exists
    Given Reviews left by the user exist
    And seller respond to review
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees sorting reviews dropdown with selected Left by this seller option
    And Review for buyer
    When Visitor clicks on Left by this buyer option
    Then List of reviews should be updated

  Scenario: Reviews left by this seller/buyer not shown when show_reviews_if_both_completed
    Given User exists
    Given Rating systems exists
    And seller respond to review
    Given TransactableType has show_reviews_if_both_completed field set to true
    Given Visitor goes to the user page
    When Goes to reviews tab
    And should not see Review for buyer

  Scenario: Reviews left by this seller/buyer shown when show_reviews_if_both_completed
    Given User exists
    Given Rating systems exists
    Given Reviews left by the user exist
    Given seller respond to review
    Given TransactableType has show_reviews_if_both_completed field set to true
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees sorting reviews dropdown with selected Left by this seller option
    And Review for buyer

  Scenario: Reviews left by this seller/buyer shown with pagination
    Given User exists
    Given Rating systems exists
    Given Reviews left by the user exist for pagination
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees sorting reviews dropdown with selected Left by this seller option
    And Pagination with active first page
    When Visitor clicks on next page
    Then Sees second page
