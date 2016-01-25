Feature: Marketplace can be multi-lingual

  Background:
    Given another languages exists
    And we have translations in place

  Scenario: I change language
    Given I am on the home page
    Then I should see "Log In"
    And I change language to "cs"
    Then I should see "Přihlásit se"
    And I change language to "pl"
    Then I should see "Zaloguj się"

  # Fallback to primary language
  Scenario: I change language to not existing one
    Given I am on the home page
    Then I should see "Log In"
    And I change language to not existing one
    Then I should see "Log In"

  # Fallback to English
  Scenario: Key does not exist in selected language
    Given I am on the home page
    And I change language to "cs"
    Then I should see "Přihlásit se"
    And I should see "Sign Up"

  Scenario: Primary language is not English
    Given default language is not English
    And I am on the home page
    Then I should see "Přihlásit se"
    And I change language to "en"
    Then I should see "Log In"
    And I reload page without language parameter
    Then I should see "Log In"

  Scenario: User can set his own language
    Given a user exists
    And I am logged in as the user
    And I am on the home page
    And I should see "Messages"
    Then the user sets his language preferences to "cs"
    And I am on the home page
    Then Language should be "cs"
    And I should see "Zprávy"
    Then the user sets his language preferences to "pl"
    And I am on the home page
    Then Language should be "pl"
    Then I should see "Wiadomości"
