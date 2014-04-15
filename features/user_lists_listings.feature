Feature: User Lists listings
  In order to browse the listings
  As a user
  I want to see a transactable of newly-created listings

  Scenario: view listings
    Given a transactable exists with name: "Mocra"
    And a transactable exists with name: "Inspire9"
    When I go to the transactables page
    Then I should see the following listings in order:
      | Inspire9 |
      | Mocra |
