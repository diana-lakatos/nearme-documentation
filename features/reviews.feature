@javascript
Feature: User can rate a reservation
  Scenario: A guest rates host of a reservation with selected rating
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host and listing rating
    When I submit host rating with valid values
    Then I should see success message and no errors

  Scenario: A guest rates host of a reservation with unselected rating
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host and listing rating
    When I submit host rating with invalid values
    Then I should see error message

  Scenario: A guest updates a review with selected rating
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host and listing rating
    When I edit host rating with valid values
    Then I should see updated feedback

  Scenario: A guest updates a review with unselected rating
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host and listing rating
    When I edit host rating with invalid values
    Then I should see error message

  Scenario: A guest deletes a review
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host and listing rating
    When I remove review
    Then I should see review in uncompleted feedback
