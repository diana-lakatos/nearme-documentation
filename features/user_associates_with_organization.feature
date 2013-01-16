Feature: User associates with organization

  @broken
  Scenario: success
    Given an organization exists with name: "Order of the Phoenix"
    And a user exists
    And I am logged in as the user
    When I add myself as a member of the organization
    Then I am a member of the organization
