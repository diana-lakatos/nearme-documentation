Feature: User Lists listings
  In order to browse the listings
  As a user
  I want to see a listing of newly-created listings

  Scenario: view listings
    Given a listing exists with name: "Mocra"
    And I am on the home page
    When I go to the listings page
    Then I should see the following listings in order:
      | Mocra |
    Given a listing exists with name: "Inspire9"
    When I go to the listings page
    Then I should see the following listings in order:
      | Inspire9 |
      | Mocra |
