Feature: A user can see location details
  In order to make a reservation
  As a user
  I want to see location details

  Background:
    Given a company exists
      And a location exists with company: that company
      And a listing: "Big room" exists with location: that location, name: "Big room", quantity: 10

  Scenario: Selected listing is highlighted
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10
     When I am on the listing "Small room" page
     Then I should see highlighted listing: "Small room" 
      And I should see "Big room"
