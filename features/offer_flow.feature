@javascript
Feature: Offer like end to end flow
  Background:
    Given UoT instance is loaded
    And a enquirer exists
    And a lister exists
    And stripe_connect_payment_gateway exists

  Scenario: 'Enquirer fills out profile'
    Given I am logged in as enquirer
    When I go to the payouts page
    Then I should see "Please complete your profile first."
    When I fill all required buyer profile information
    And I press "Save"
    Then I should see "You have updated your account successfully"
    When I go to the payouts page
    Then I should see "Merchant account details"

  Scenario: 'Lister fills out profile'
    Given I am logged in as lister
    When I go to the payouts page
    Then I should see "Please complete your profile first."
    When I fill all required seller profile information
    And I press "Submit"
    Then I should see "Your Project was listed!"
    When I go to the dashboard page
    And I click element with selector "#dashboard-nav-transactables"
    And I follow "Add a Project"
    Then I can add new project
    And I should see "Great, your new Project has been added!"
    When I go to enquirer's page
    And I invite enquirer to my project

  Scenario: 'Lister accepts an offer'
    Given a registered_lister exists
    And an unconfirmed_offer exists
    When I am logged in as registered_lister
    And I go to the dashboard page
    And I click element with selector "#dashboard-nav-transactables"
    And I follow "My Listings"
    Then I should see "SMEs Invited (1)"
    And I follow "Accept"
    And I wait for modal with credit card fields to render
    When I fill credit card payment subscription form
    Then offer is confirmed
    And my credit card is saved

  Scenario: 'Lister accepts pro bono offer'
    Given a registered_lister exists
    And a free_transactable_offer exists
    And an unconfirmed_offer exists
    When I am logged in as registered_lister
    And I go to the dashboard page
    And I click element with selector "#dashboard-nav-transactables"
    And I follow "My Listings"
    Then I should see "SMEs Invited (1)"
    And I follow "Accept"
    And I wait for modal with credit card fields to render
    When I fill credit card payment form
    Then offer is confirmed
    And my credit card is saved
    And payment for 100$ was created
