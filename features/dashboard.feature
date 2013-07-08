@javascript
Feature: As a user of the site
  In order to promote my company
  As a user
  I want to manage my locaations

  Background:
    Given a user exists
      And I am logged in as the user
      And a company exists with creator: the user
      And a location_type exists with name: "Business"
      And a location_type exists with name: "Co-working"
      And a listing_type exists with name: "ListingType1"
      And a listing_type exists with name: "ListingType2"
      And a amenity_type exists with name: "AmenityType1"
      And a amenity exists with amenity_type: the amenity_type, name: "Amenity1"
      And a amenity exists with amenity_type: the amenity_type, name: "Amenity2"
      And a amenity exists with amenity_type: the amenity_type, name: "Amenity3"

  Scenario: A user can add new location
    Given I am on the manage locations page
     When I follow "Create New Location"
      And I fill location form with valid details
      And I submit the form
     Then Location with my details should be created
     
  Scenario: A user can edit existing location
    Given the location exists with company: the company
      And I am on the manage locations page
     When I click edit icon
      And I provide new location data
      And I submit the form
     Then the location should be updated
     When I click edit icon
      And I click delete location link
     Then the location should not exist

  Scenario: A user can add new listing
    Given the location exists with company: the company
      And I am on the manage locations page
     When I follow "Add Listing"
      And I fill listing form with valid details
      And I submit the form
     Then Listing with my details should be created

  Scenario: A user can edit existing listing
    Given the location exists with company: the company
      And the listing exists with location: the location
      And I am on the manage locations page
     When I click edit listing icon
      And I provide new listing data
      And I submit the form
     Then the listing should be updated
     When I click edit listing icon
      And I click delete listing link
     Then the listing should not exist

  Scenario: A user can disable existing price in listing
    Given a location exists with company: the company
      And a listing exists with location: the location, daily_price_cents: 1000
      And I am on the manage locations page
     When I click edit listing icon
      And I disable daily pricing
      And I submit the form
      And I click edit listing icon
     Then Listing daily pricing should be disabled

  Scenario: A user can enable new pricing in listing
    Given a location exists with company: the company
      And a listing exists with location: the location, daily_price_cents: 1000
      And I am on the manage locations page
     When I click edit listing icon
      And I enable weekly pricing
      And I submit the form
      And I click edit listing icon
     Then Listing weekly pricing should be enabled

  Scenario: A user can set availability rules on a listing
    Given a location exists with company: the company
    And   a listing exists with location: the location
    And   I am on the manage locations page
    When I click edit listing icon
    And  I select custom availability:
        | Day | Availabile | Open Time | Close Time |
        | 1   | Yes        | 9:00      | 17:00      |
        | 2   | Yes        | 9:00      | 17:00      |
    And I submit the form
    Then the listing should have availability:
        | Day | Availabile | Open Time | Close Time |
        | 1   | Yes        | 9:00      | 17:00      |
        | 2   | Yes        | 9:00      | 17:00      |


