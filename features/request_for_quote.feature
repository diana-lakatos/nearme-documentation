@javascript
Feature: A user can recurre book at a space
  In order to have a place to work
  As a user
  I want to request for quote transactable

  Background:
    Given a company exists
      And a location exists with company: that company
      And a transactable exists with location: that location, quantity: 10, photos_count: 1, currency: "USD"
      And a transactable has action_rfq
      And a user exists with name: "John Doe"
      And request for feature is enabled

  Scenario: As an anonymous user I should return to my request for quote after logging in
    When I go to the transactable's page
    When I select to request quote and review space for:
      | Transactable     | Date   | Quantity |
      | the transactable | Monday | 2        |
    And I log in to continue booking
    Then I should see the request for quote screen for:
      | Transactable     | Date   | Quantity |
      | the transactable | Monday | 2        |

  Scenario: Hourly reserved listing can be requested for quote
    Given the transactable is reserved hourly
      And the transactable has an hourly price of 100.00
      And I am logged in as the user
     When I go to the transactable's page
     When I select to request quote and review space for:
        | Transactable     | Date   | Quantity | Start | End   |
        | the transactable | Monday | 1        | 9:00  | 14:00 |
    Then I should see the request for quote screen for:
       | Transactable     | Date   | Quantity | Start | End   |
       | the transactable | Monday | 1        | 9:00  | 14:00 |


