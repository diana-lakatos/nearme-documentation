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

  Scenario: Verify account with errors if Stripe allows trasnfers and charges
    When I go to the payouts page
    And I set Stripe to respond with disabled_reason rejected.fraud
    And I update Stripe merchant form
    Then Stripe rejected.fraud error should be presented to user
    And verified merchant account should be created
    And due_by should be displayed

  Scenario: Present errors to the user
    Given failed_stripe_connect_merchant_account is persisted
    When I go to the payouts page
    Then I should see all persisted errors

  Scenario: should remain pending if not yet verified
    When I go to the payouts page
    And I set Stripe to respond with transfer_disabled and disabled_reason rejected.fraud
    And I update Stripe merchant form
    Then Stripe rejected.fraud error should be presented to user
    And pending merchant account should be created
