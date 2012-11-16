Feature: A user can book at a space
  In order to have a place to work
  As a user
  I want to book a listing

  Background:
    Given a company exists
      And a location exists with company: that company
      And a listing exists with location: that location, quantity: 10
      And a user exists

  @wip
  @javascript
  Scenario: A logged in user can book a listing
    Given I am logged in as the user
     When I go to the location's page
      And I choose to book space for:
          | listing      | date    | quantity |
          | the listing | Monday  | 1        |
          | the listing | Tuesday | 1        |
      And the user should have the listing reserved for 'Monday'
      And the user should have the listing reserved for 'Tuesday'


