Feature: Space owner manages guests
  In order to understand who is coming to my space
  As a space owner
  I want to see a list of upcoming guests

  @not_implemented
  Scenario: No guests scheduled
    Given I am logged in as a space owner
    And none of my spaces have reservations
    When I visit the manage guests page
    Then I am given the opportunity to share each of my spaces via Twitter
    And I am shown a link to each space I share however I want
