@javascript
Feature: Guest can rate a reservation
  Background:
    Given Reservation alerts exist
    And I am guest of a reviewable reservation
    And I log in as user
    And a company exists with creator: the user
    And a location exists with company: the company
    And a transactable exists with location: the location

  Scenario: A guest rates host of a reservation with selected rating
    And I receive an email request for host and listing rating
    When I submit rating with valid values
    Then I should see success message and no errors

  Scenario: A guest rates host of a reservation with unselected rating
    And I receive an email request for host and listing rating
    When I submit rating with invalid values
    Then I should see error message

  Scenario: A guest updates a review with selected rating
    When I edit host rating with valid values
    Then I should see updated feedback

  Scenario: A guest updates a review with unselected rating
    When I edit host rating with invalid values
    Then I should see error message

  Scenario: A guest updates a review with selected rating
    When I edit transactable rating with valid values
    Then I should see updated feedback

  Scenario: A guest updates a review with unselected rating
    When I edit transactable rating with invalid values
    Then I should see error message

  Scenario: A guest updates a review with selected rating
    When I edit transactable rating with valid values
    Then I should see updated feedback

  Scenario: A guest deletes a review
    When I remove review
    Then I should see review in uncompleted feedback
