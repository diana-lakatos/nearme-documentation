Feature: List organizations
  In order to discover the organizations
  As an API client
  I want to list organizations

  Scenario: GET /organizations
    Given an organization with logo named AICPA
    And an organization named Lawyers USA
    When I send a GET request for "organizations"
    Then the response should have the AICPA organization
    Then the response should have the Lawyers USA organization
