@javascript
Feature: Host can rate a reservation
  Background:
    Given Reservation alerts exist
    And I am host of a reviewable reservation
    And I log in as user
    And a company exists with creator: the user
    And a location exists with company: the company
    And a transactable exists with location: the location

  Scenario: A host rates guest of a reservation with selected rating
    When I submit rating with valid values
    Then I should see success message and no errors

  Scenario: A host rates guest of a reservation with unselected rating
    When I submit rating with invalid values
    Then I should see error message

  Scenario: A host updates a review with selected rating
    When I edit guest rating with valid values
    Then I should see updated feedback

  Scenario: A host updates a review with unselected rating
    When I edit guest rating with invalid values
    Then I should see error message
