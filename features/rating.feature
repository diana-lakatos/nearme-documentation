@javascript
Feature: A user can rate a booking
  In order to leave feedback for other users
  As a user
  I want to be able to rate a booking

  Scenario: A guest rates host of a reservation
    Given I am guest of a past reservation
    And I log in as user
    And I receive an email request for host rating
    When I submit a host rating with comment and good rating
    Then I should be redirected to mainpage
    And hosts rating should be recalculated

  Scenario: A host rates guest of his listing
    Given I am host of a past reservation
    And I log in as user
    And I receive an email request for guest rating
    When I submit a guest rating with comment and good rating
    Then I should be redirected to mainpage
    And guests rating should be recalculated
