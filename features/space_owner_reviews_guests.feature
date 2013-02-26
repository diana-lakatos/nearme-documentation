Feature: Space owner manages guests
  In order to understand who is coming to my space
  As a space owner
  I want to see a list of upcoming guests

  @wip
  Scenario: No guests scheduled
    Given I am logged in as a space owner without guests
    When I visit the manage guests page
    Then I am given the opportunity to share each of my spaces via Twitter
