Feature: List organizations
  In order to discover the organizations
  As an API client
  I want to list organizations

  @borked
  Scenario: GET /organizations
    Given no organizations
    When I send a GET request for "organizations"
    Then the response should be an empty organizations list
