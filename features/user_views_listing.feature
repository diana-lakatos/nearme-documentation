Feature: User Views Listing

  Scenario: user who is a member of locations organization may view a private listing
    Given a listing exists for a location with a private organization
    When I log in as a user who is a member of that organization
    And I visit that listing
    And I see the listing details

  Scenario: anonymous user may not view a private listing
    Given a listing exists for a location with a private organization
    When I visit that listing
    Then I cannot view that listing
