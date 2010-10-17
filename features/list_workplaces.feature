Feature: List workplaces
  In order to browse the workplaces
  As a user
  I want to see a listing of newly-created workplaces
  
  Scenario: view workplaces
    Given a workplace exists with name: "Mocra"
    And I am on the home page
    When I follow "Workplaces"
    Then I should see the following workplaces in order:
      | Mocra |
    Given a workplace exists with name: "Inspire9"
    When I follow "Workplaces"
    Then I should see the following workplaces in order:
      | Inspire9 |
      | Mocra    |

