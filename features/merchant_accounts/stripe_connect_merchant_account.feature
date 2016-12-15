# Use allow_connections profile for real API advantures

@javascript
Feature: Stripe Connect Merchant flow
  As a user
  I want to manage my merchant data

  Background:
    Given a user exists
    And a company exists with creator: the user
    And I remove all payment gateways
    And the stripe_connect_payment_gateway exists
    And I am logged in as the user

  Scenario: A user can add new merchant account
    When I go to the payouts page
    And I update Stripe merchant form
    Then summary table should be displayed
    And verified merchant account should be created
    And there should be no errors

  Scenario: display proper error on failure
    When I go to the payouts page
    And I set Stripe to respond with rejected.fraud
    And I update Stripe merchant form
    Then Stripe rejected.fraud error should be presented to user
    And failed merchant account should be created

  Scenario: merchant account errors should be presented
    Given failed_stripe_connect_merchant_account is persisted
    When I go to the payouts page
    Then I should see all persisted errors
