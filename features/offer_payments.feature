@javascript @offer_flow

Feature: Offer like end to end flow
  Background:
    Given UoT instance is loaded
    And I remove all payment gateways
    And stripe_connect_payment_gateway exists
    And only credit_card payment_method is set
    Given a lister exists with email: "lister@near-me.com"
    Given company exists with name: "Lister Company", email: "lister@near-me.com", creator: lister
    Given a registered_enquirer exists with email: "enquirer@near-me.com"
    Given company exists with name: "Enquirer Company", email: "enquirer@near-me.com", creator: registered_enquirer

  Scenario: 'Lister accepts an offer with ach payment'
    Given I remove all payment gateways
    And direct_stripe_sconnect_payment_gateway exists
    And I stub source creation with latest VCR
    And an unconfirmed_offer exists
    When I am logged in as lister
    And I go to the dahboard transactables list
    When I accept the offer
    And fill ACH payment form
    Then I should see "You have successfuly added credit card and accepted an offer"
    When I cancel the project
    Then I should see "Archived (1)"

  Scenario: 'Lister accepts an ProBono offer when payment gateway is set to direct payment'
    Given I remove all payment gateways
    And I stub credit_card creation with latest VCR
    And finders fee is set to 55$
    And direct_stripe_sconnect_payment_gateway exists
    And registered_enquirer has valid merchant account
    And a free_transactable_offer exists with creator: lister
    And an unconfirmed_offer exists with user: registered_enquirer
    When I am logged in as lister
    And I go to the dahboard transactables list
    When I accept the offer
    And I fill credit card payment form
    Then offer is confirmed
    And my credit card is saved
    And paid payment for 55$ should exist

  Scenario: 'Lister accepts an offer'
    And an unconfirmed_offer exists
    When I am logged in as lister
    And I go to the dashboard page
    And I click element with selector "#dashboard-nav-transactables"
    And I follow "My Listings"
    Then I should see "SMEs Invited (1)"
    When I accept the offer
    And I fill credit card payment subscription form
    Then offer is confirmed
    And my credit card is saved

  Scenario: 'Lister accepts pro bono offer'
    And a free_transactable_offer exists with creator: lister
    And an unconfirmed_offer exists with user: registered_enquirer
    When I am logged in as lister
    And I go to the dashboard page
    And I click element with selector "#dashboard-nav-transactables"
    And I follow "My Listings"
    Then I should see "SMEs Invited (1)"
    When I accept the offer
    And I fill credit card payment form
    Then offer is confirmed
    And my credit card is saved
    And payment for 100$ was created

  Scenario: 'Enquirer sends expenses'
    Given confirmed offer exists with user: registered_enquirer
    And I am logged in as registered_enquirer
    And I go to the dahboard transactables in progress list
    And I follow "TRACK TIME & EXPENSES"
    Then I should see modal with payout missing information
    When I follow "SET UP PAYMENT TRANSFERS"
    And I stub sending stripe documents
    And I update Stripe merchant form
    And I go to the dahboard transactables in progress list
    And I follow "TRACK TIME & EXPENSES"
    When I fill time expenses with:
        |Building website|  Build nice website   |20|100|
        |Building tests  |    Test with cucmber  |10|100|
    And I fill item expenses with:
        |New PC    |  Need new gear to work with  |1|5000|
        |New Tablet|  Need new gear to work with  |1|3000|

    And I fill in "recurring_booking_period_comment" with "My first invoice"
    Then I should see "Total cost: $11000.00"
    When I press "Submit invoice"
    Then I should see "Order item has been created."
    And unaccepted order item should be generated
    And 30% host fee should be added to each time expense:
      |Building website| 30% of $2000  | $600|
      |Building tests  | 30% of $1000  | $300|
      |Total host fee  | 30% of $3000  | $900|

  Scenario: 'Lister approves expenses'
    Given I remove all payment gateways
    And direct_stripe_sconnect_payment_gateway exists
    Given a transactable_offer exists with creator: lister
    Given a confirmed_offer: "Order" exists with user: registered_enquirer
    And I stub source creation with latest VCR
    Given credit_card is prcessed with Stripe
    And the following order_items exist:
     | order_item     | order           |
     | First Invoice  | confirmed_offer |
     | Second Invoice | confirmed_offer |
    And the following transactable_line_items exist:
     | name     | type                  | quantity | unit_price_cents | line_itemable               | line_item_source   |
     | 1.1 Time | LineItem::Transactable| 2        | 2000             | order item "First Invoice"  | transactable_offer |
     | 1.2 Time | LineItem::Transactable| 1        | 6000             | order item "First Invoice"  | transactable_offer |
     | 2.1 Time | LineItem::Transactable| 1        | 12000            | order item "Second Invoice" | transactable_offer |
    And the following additional_line_items exist:
     | name     | type                  | quantity | unit_price_cents | line_itemable               | line_item_source   | receiver |
     | 1.3 Item | LineItem::Additional  | 3        | 1000             | order item "First Invoice"  | transactable_offer | host     |
     | 1.4 Item | LineItem::Additional  | 1        | 17000            | order item "First Invoice"  | transactable_offer | host     |
     | 2.3 Item | LineItem::Additional  | 1        | 22000            | order item "Second Invoice" | transactable_offer | host     |
    When I am logged in as lister
    And I go to the dahboard transactables in progress list
    And I follow "View Time & Expenses"
    Then I should see "We are processing SME's bank account details"
    And Approve should be disabled
    When I come back when registered_enquirer has valid merchant account
    When I approve first invoice
    Then I should see all text:
      |Order item has been approved.|
      |Approved                     |
      |Paid                         |
    When I reject other invoice
    Then I should see all text:
      |Order item has been rejected.|
      |Rejected                     |
      |Unpaid                       |
      |Total Unpaid: $0             |
    Then I verify invoices state:
      |invoice                     | state    | total  | payment state | payment total |
      |order item "First Invoice"  | approved | 300    | paid          | 300           |
      |order item "Second Invoice" | rejected | 340    |               | 0             |
