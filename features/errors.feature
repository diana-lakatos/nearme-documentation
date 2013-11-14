Feature: Errors happens
Background:
  Given an instance exists

Scenario: Display information page if domain not configured
  Given I am on the not configured domain page
  Then I should see "The domain has not been configured"
