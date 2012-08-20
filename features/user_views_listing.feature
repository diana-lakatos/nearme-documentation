Feature: User Views Listing
  Scenario: Viewing a free listing
    Given a listing exists with price_cents: 0
    Then the listing price is shown as Free

  Scenario: Viewing a Listing with Amenities
    Given a listed location with an amenity
    When I view that listing
    Then I see that amenity
