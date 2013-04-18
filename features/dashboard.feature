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
    Given a location exists with company: the company
      And I am on the manage locations page
     When I click edit icon
      And I provide new location data
      And I submit the form
     Then Location should be updated
     When I click edit icon
     When I follow "Delete this location"
     Then Location has been deleted

  Scenario: A user can add new listing
    Given a location exists with company: the company
      And I am on the manage locations page
     When I follow "Create New Listing"
      And I fill listing form with valid details
      And I submit the form
     Then Listing with my details should be created

  Scenario: A user can edit existing listing
    Given a location exists with company: the company
      And a listing exists with location: the location
      And I am on the manage locations page
     When I click edit listing icon
      And I provide new listing data
      And I submit the form
     Then Listing should be updated
     When I click edit listing icon
     When I follow "Delete this listing"
     Then Listing has been deleted
