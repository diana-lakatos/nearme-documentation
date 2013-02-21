Feature: User Lists guests
  In order to browse the guests
  As a user
  I want to see a listing of newly-created guests

  Scenario: no guests
    Given a user exists
      And I am logged in as the user
      And no guests exists
    When I go to the guests page
    Then I should see a link "Share your space" 
