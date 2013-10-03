Feature: A user can see location details
  In order to make a reservation
  As a user
  I want to see location details

  Background:
    Given a company exists
      And a location exists with company: that company, address: "Adelaide"
      And a listing: "Big room" exists with location: that location, name: "Big room", quantity: 10

  Scenario: Selected listing is highlighted
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10
     When I am on the listing "Small room" page
     Then I should see highlighted listing: "Small room" 
      And I should see "Big room"

  Scenario: User is redirected to search page if he tries to access deleted listing
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10
      And a listing: "Small Room" is deleted
     When I am on deleted listing "Small room" page
     Then I should see other listings near "Adelaide"

  Scenario: User is redirected to search page if he tries to access deleted listing, which location is also deleted
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10
      And a listing: "Small Room" is deleted
     When I am on listing "Small room" page which belong to deleted location
     Then I should see other listings near "Adelaide"

  Scenario: User is redirected to search page if he tries to access deleted location
    Given a location is deleted
     When I am on deleted location page
     Then I should see other listings near "Adelaide"
      And I should not see "Big Room"

  Scenario: User is redirected to location with first listing if no listing given
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10
    When I go to the location page
    Then I should be redirected to the first listing page

  Scenario: User is redirected to search page if he tries to access disabled listing
    Given a listing: "Small room" exists with location: that location, name: "Small room", quantity: 10, enabled: false
      And a listing: "Small Room" is disabled
     When I am on the listing "Small room" page
     Then I should see "This listing has been temporarily disabled by the owner. Check out some others near you!"
