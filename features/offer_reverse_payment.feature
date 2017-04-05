@javascript @offer_flow

Feature: Offer prices and fees for localdriva
  Background:
    Given Localdriva instance is loaded
    And direct_stripe_sconnect_payment_gateway_au exists
    Given passenger exists with email: "passenger@near-me.com"
    Given company exists with name: "Enquirer Company", email: "passenger@near-me.com", creator: passenger
    Given a localdriva driver exists
    Given company exists with name: "Enquirer Company", email: "enquirer@near-me.com", creator: driver
    And driver has valid merchant account
    And localdriva booking exists
    When I am logged in as driver

  Scenario: 'Driver accepts a booking with pricing fee set'
    And service fee for pricing 1_item is set to 10%
    And service fee for pricing 3_item is set to 20%
    And I go to the dahboard transactables list
    Then I should see correct price of 76
    Then I accept booking
    Then I should see correct price of 76
    Then I log out
    When I am logged in as passenger
    And I go to the dahboard transactables list
    Then I should see correct price of 83.60
    Then I should see correct service fee of 7.60
    And offer shoud have total of: 83.60 and fee of 7.60
    Then I log out
    When I am logged in as driver
    When I edit driver's type to Plus
    And localdriva booking exists
    And I go to the dahboard transactables list
    Then I should see correct price of 90
    Then I accept booking
    And offer shoud have total of: 108 and fee of 18
    Then I log out
    When I am logged in as passenger
    And I go to the dahboard transactables list
    Then I should see correct price of 108
    Then I should see correct service fee of 18

  Scenario: 'Driver accepts a booking with action fee set'
    And service fee for action is set to 15%
    And I go to the dahboard transactables list
    Then I should see correct price of 76
    Then I accept booking
    Then I should see correct price of 76
    Then I log out
    When I am logged in as passenger
    And I go to the dahboard transactables list
    Then I should see correct price of 87.40
    Then I should see correct service fee of 11.40
    And offer shoud have total of: 87.40 and fee of 11.40
