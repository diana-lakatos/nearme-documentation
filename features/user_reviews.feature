@javascript
Feature: Reviews for user are shown on user page
    Scenario: Blank state is shown if there are no reviews for user
    Given User exists
    Given Rating systems exists
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees no reviews blank state

  Scenario: Reviews about seller are shown
    Given Rating systems exists
    Given Reviews about the seller exist
    Given Visitor goes to the user page
    When Goes to reviews tab
    Then Sees one seller reviews

