@javascript

Feature: Offer like end to end flow
  Background:
    Given UoT instance is loaded

  Scenario: 'Enquirer fills out profile'
    Given a enquirer exists
    Given company exists with name: "Enquirer Company", email: "enquirer@near-me.com", creator: enquirer
    And stripe_connect_payment_gateway exists
    When I am logged in as enquirer
    Then I go to the payouts page
    Then I should see "Please complete your profile first."
    When I fill all required buyer profile information
    And I press "Save"
    Then I should see "You have updated your account successfully"
    When I go to the payouts page
    Then I should see "Merchant account details"

  Scenario: 'Lister fills out profile'
    Given a lister exists
    Given a enquirer exists
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
