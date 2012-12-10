Feature: User Views Listing

  @future
  Scenario: Viewing a Listing with Amenities
    Given a listed location with an amenity
    When I view that listing
    Then I see that amenity

  Scenario: user who is a member of locations organization may view a private listing
    Given a listing exists for a location with a private organization
    When I log in as a user who is a member of that organization
    And I visit that listing
    And I see the listing details

  Scenario: anonymous user may not view a private listing
    Given a listing exists for a location with a private organization
    When I visit that listing
    Then I cannot view that listing
